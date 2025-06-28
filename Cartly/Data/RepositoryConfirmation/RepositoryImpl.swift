import Combine

class RepositoryImpl: RepositoryProtocol,DraftOrderRepositoryProtocol,DeleteEntireDraftOrderUseCaseProtocol{
    private let remoteDataSource: RemoteDataSourceProtocol
    private let firebaseRemoteDataSource: FirebaseDataSourceProtocol
    
    init(remoteDataSource: RemoteDataSourceProtocol, firebaseRemoteDataSource: FirebaseDataSourceProtocol) {
        self.remoteDataSource = RemoteDataSourceImpl(networkService: AlamofireService())
        self.firebaseRemoteDataSource = firebaseRemoteDataSource
    }
    
    func fetchBrands() -> AnyPublisher<[BrandMapper], Error> {
        return remoteDataSource.fetchBrands()
            .tryMap {
                guard let collections = $0?.smartCollections else {
                    throw ErrorType.noData
                }
                return DataMapper.createBrands(from: collections)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchProducts(for collectionID: Int64) -> AnyPublisher<[ProductMapper], any Error> {
        return remoteDataSource.fetchProducts(from: collectionID)
            .tryMap {
                guard let products = $0?.products else {
                    throw ErrorType.noData
                }
                return DataMapper.createProducts(from: products)
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAllProducts() -> AnyPublisher<[ProductMapper], any Error> {
        return remoteDataSource.fetchAllProducts()
            .tryMap {
                guard let products = $0?.products else {
                    throw ErrorType.noData
                }
                return DataMapper.createProducts(from: products)
            }
            .eraseToAnyPublisher()
    }
    
    func getSingleProduct(for productId: Int64) -> AnyPublisher<SingleProductResponse?, any Error> {
        return remoteDataSource.getSingleProduct(for: productId)
    }
    
    func getCustomers() -> AnyPublisher<AllCustomerResponse?, any Error> {
        return remoteDataSource.getCustomers()
    }
    
    func getSingleCustomer(for customerId: String) -> AnyPublisher<CustomerResponse?, any Error> {
        return remoteDataSource.getSingleCustomer(for: customerId)
    }
    
    func getWishlistProductsForUser(whoseId id: String) -> AnyPublisher<[WishlistProduct]?, any Error> {
        return firebaseRemoteDataSource.getWishlistProductsForUser(whoseId: id)
    }
    
    func addWishlistProductForUser(whoseId id: String, withProduct product: WishlistProduct) -> AnyPublisher<Void, any Error> {
        firebaseRemoteDataSource.addWishlistProductForUser(whoseId: id, withProduct: product)
    }
    
    func removeWishlistProductForUser(whoseId id: String, withProduct productId: String) -> AnyPublisher<Void, any Error> {
        firebaseRemoteDataSource.removeWishlistProductForUser(whoseId: id, withProduct: productId)
    }
    
    func isProductInWishlist(withProduct productId: String, forUser id: String) -> AnyPublisher<Bool, any Error> {
        firebaseRemoteDataSource.isProductInWishlist(withProduct: productId, forUser: id)
    }
    
    /// normal function for normal restAPI requests for order
    func fetchAllDraftOrders() -> AnyPublisher<DraftOrdersResponse?, Error> {
        remoteDataSource.fetchAllDraftOrders()
            .eraseToAnyPublisher()
    }
    
    /// normal function for normal restAPI requests for order
    func postNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<DraftOrder?, Error> {
        remoteDataSource.postNewDraftOrder(cartEntity: cartEntity)
            .eraseToAnyPublisher()
    }
    
    /// normal function for normal restAPI requests for order
    func editDraftOrder(draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error> {
        remoteDataSource.editExistingDraftOrder(draftOrder: draftOrder)
            .eraseToAnyPublisher()
    }
    
    /// contains some logic and work around work for post or edit new order for customer
    ///  هنا عشان تعمل ادد محتاج في الاول تجيب كل ال درافت اوردرز وهتعمل فيلتر فال ايميل الي معاك عشان تشوف
    ///  هو عنده اوردر ولا لا لو عنده، فمحتاج تعرف الفارينت الي معاك موجود ضمن المنتجات الموجوده في الاوردر ولا لا
    ///  لو موجود فهتعمل تعديل للمنتج ده بالكميه الجديده وهتعمل put request
    ///  لو مش موجوده هتضيف المنتج بتاعك ده علي ال line items array then put request with whole object
    ///  طيب لو فالاول خالص الايميل معندوش اوردرات اتعملت قبل كدا هتعمل post request
    ///  بالداتاا الي هتكون معاك في الكارت بس كده
    func addToCart(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error> {
        fetchAllDraftOrders() /// بجيب كل الدرافت اوردرز
            .flatMap { [weak self] draftOrdersResponse -> AnyPublisher<CustomSuccess, Error> in
                guard let self = self else {
                    return Fail(error: ErrorType.failUnWrapself).eraseToAnyPublisher()
                }
                
                /// من الريسبونس الي راجع بجيب الاراي بتاعت الدرافت اوردرز
                let draftOrders = draftOrdersResponse?.draftOrders ?? []
                
                /// هنا بفصل اللوجيك بتاع ال edge cases
                return self.processCartLogic(cartEntity: cartEntity, existingDraftOrders: draftOrders)
            }
            .eraseToAnyPublisher()
    }
    
    func deleteExistingDraftOrder(draftOrderID: Int64, itemID: Int64) -> AnyPublisher<[CartMapper], Error> {
        print("in delete in repository!!!")
        return fetchAllDraftOrders()
            .flatMap { [weak self] draftOrdersResponse -> AnyPublisher<[CartMapper], Error> in
                guard let self = self else {
                    return Fail(error: ErrorType.failUnWrapself).eraseToAnyPublisher()
                }
                
                let draftOrders = draftOrdersResponse?.draftOrders ?? []
                print("checking if draftorder when delete item in cart is empty or not in repository file: \(draftOrders.isEmpty)")
                return self.performDeletionOfDraftOrder(draftOrders: draftOrders, draftOrderID: draftOrderID, itemID: itemID)
            }
            .eraseToAnyPublisher()
    }
    
    func performDeletionOfDraftOrder(
        draftOrders: [DraftOrder],
        draftOrderID: Int64,
        itemID: Int64
    ) -> AnyPublisher<[CartMapper], Error> {
        guard let matchingDraftOrder = draftOrders.first(where: { $0.id == draftOrderID }) else {
            print("Draft order with ID \(draftOrderID) not found")
            return Fail(error: ErrorType.noData).eraseToAnyPublisher()
        }
        
        let currentLineItems = matchingDraftOrder.lineItems ?? []
        
        let newLineItems = currentLineItems.filter { $0.id != itemID }
        
        if newLineItems.isEmpty {
            print("No items left in cart, deleting entire draft order")
            return remoteDataSource.deleteExistingDraftOrder(draftOrderID: draftOrderID)
                .tryMap { isDeleted in
                    if isDeleted {
                        print("Draft order deleted successfully")
                        return []
                    } else {
                        throw ErrorType.badServerResponse
                    }
                }
                .eraseToAnyPublisher()
        } else {
            print("Items remaining (\(newLineItems.count)), updating draft order")
            var updatedDraftOrder = matchingDraftOrder
            updatedDraftOrder.lineItems = newLineItems
            return remoteDataSource.editExistingDraftOrder(draftOrder: updatedDraftOrder)
                .tryMap { updatedDraftOrder in
                    guard let updatedOrder = updatedDraftOrder else {
                        throw ErrorType.badServerResponse
                    }
                    print("Draft order updated successfully")
                    return [CartMapper(draft: updatedOrder)]
                }
                .catch { error -> AnyPublisher<[CartMapper], Error> in
                    print("Failed to update draft order, refreshing cart: \(error)")
                    return self.getAllDraftOrdersForCustomer()
                }
                .eraseToAnyPublisher()
        }
    }
    
    private func processCartLogic(cartEntity: CartEntity, existingDraftOrders: [DraftOrder]) -> AnyPublisher<CustomSuccess, Error> {
        print("Processing cart logic for email: \(cartEntity.email)")
        print("Found \(existingDraftOrders.count) existing draft orders")
        /// اول حاجه هشوف الايميل الي معايا عنده درافت اوردر ولا لا
        var matchingDraftOrder: DraftOrder?
        for draftOrder in existingDraftOrders {
            if let draftOrderEmail = draftOrder.email, draftOrderEmail == cartEntity.email {
                matchingDraftOrder = draftOrder
                break
            }
        }
        /// هشوف لو طلع عنده ولا لا لو ال unwrap success
        if let existingDraftOrder = matchingDraftOrder {
            print("Found existing draft order for email: \(existingDraftOrder.email ?? "N/A")")
            /// هشوف لو الفارينت الي هيحطه موجود بالفعل في الاوردر ولا لا
            var matchingLineItem: LineItem?
            let lineItems = existingDraftOrder.lineItems ?? []
            for lineItem in lineItems {
                if lineItem.variantId == cartEntity.variantId {
                    matchingLineItem = lineItem
                    break
                }
            }
            /// هعمل ان راب عشان اشوف الفارينت كان موجود ولا لا
            ///  لو ترو فكدا الايميل الي معايا عنده اوردر ومعاه فارينت عاوز يغير القيمه الي موجوده فيه ويعمل put request
            if let existingLineItem = matchingLineItem {
                /// Email matched + Variant  found = update existing variant
                print("Updating existing variant quantity")
                return updateExistingVariantQuantity(
                    draftOrder: existingDraftOrder,
                    existingLineItem: existingLineItem,
                    newQuantity: cartEntity.quantity
                )
            } else {
                /// Email matched + Variant not found = Add new line item
                print("Adding new line item to existing draft order")
                return addNewLineItemToExistingDraftOrder(
                    draftOrder: existingDraftOrder,
                    cartEntity: cartEntity
                )
            }
        } else {
            /// Email not found = Create new draft order
            print("Creating new draft order")
            return createNewDraftOrder(cartEntity: cartEntity)
        }
    }
    
    /// Update Existing Variant Quantity
    private func updateExistingVariantQuantity(
        draftOrder: DraftOrder,
        existingLineItem: LineItem,
        newQuantity: Int
    ) -> AnyPublisher<CustomSuccess, Error> {
        var updatedDraftOrder = draftOrder
        var updatedLineItems = draftOrder.lineItems ?? []
        
        for i in 0 ..< updatedLineItems.count {
            if updatedLineItems[i].variantId == existingLineItem.variantId {
                updatedLineItems[i].quantity = newQuantity
                print("Updated quantity from \(existingLineItem.quantity!) to \(newQuantity)")
                break
            }
        }
        
        updatedDraftOrder.lineItems = updatedLineItems
        
        return editDraftOrder(draftOrder: updatedDraftOrder)
            .map { _ in
                print("Successfully updated existing variant")
                return CustomSuccess.AlreadyExist
            }
            .eraseToAnyPublisher()
    }
    
    /// Add New Line Item to Existing Draft Order
    private func addNewLineItemToExistingDraftOrder(
        draftOrder: DraftOrder,
        cartEntity: CartEntity
    ) -> AnyPublisher<CustomSuccess, Error> {
        var updatedDraftOrder = draftOrder
        var updatedLineItems = draftOrder.lineItems ?? []
        
        /// Create new line item from cart entity
        let newLineItem = createLineItemFromCartEntity(cart: cartEntity)
        updatedLineItems.append(newLineItem)
        updatedDraftOrder.lineItems = updatedLineItems
        print("Adding new line item with variant ID: \(cartEntity.variantId)")
        return editDraftOrder(draftOrder: updatedDraftOrder)
            .map { _ in
                print("Successfully added new line item to existing draft order")
                return CustomSuccess.Added
            }
            .eraseToAnyPublisher()
    }
    
    /// Create New Draft Order
    private func createNewDraftOrder(cartEntity: CartEntity) -> AnyPublisher<CustomSuccess, Error> {
        print("Creating new draft order for email: \(cartEntity.email)")
        return postNewDraftOrder(cartEntity: cartEntity)
            .map { newDraftOrder in
                print("Successfully created new draft order with ID: \(newDraftOrder?.id ?? -1)")
                return CustomSuccess.Added
            }
            .eraseToAnyPublisher()
    }
    
    func getAllDraftOrdersForCustomer() -> AnyPublisher<[CartMapper], Error> {
        let service = UserSessionService()
        let userEmail = service.getCurrentUserEmail() ?? ""
        
        guard !userEmail.isEmpty else {
            return Fail(error: ErrorType.noData)
                .eraseToAnyPublisher()
        }
        
        return remoteDataSource.fetchAllDraftOrders()
            .tryMap { DraftOrdersResponse -> [CartMapper] in
                guard let draftOrders = DraftOrdersResponse?.draftOrders else {
                    return []
                }
                
                let customerDraftOrder = draftOrders.filter { DraftOrder in
                    guard userEmail == DraftOrder.email else {
                        return false
                    }
                    return true
                }
                
                let cartMappers = customerDraftOrder.compactMap { draftOrder -> CartMapper? in
                    guard draftOrder.id != nil,
                          draftOrder.status != nil,
                          let lineItems = draftOrder.lineItems,
                          !lineItems.isEmpty else {
                        return nil
                    }
                    return CartMapper(draft: draftOrder)
                }
                return cartMappers
            }
            .eraseToAnyPublisher()
    }
    
    func getAllProductsToGetLineItemsPhoto(cartMapper: CartMapper) -> AnyPublisher<[CartMapper], Error> {
        return remoteDataSource.fetchAllProducts()
            .map { response -> [Product] in
                guard let response = response
                else {
                    return []
                }
                return response.products
            }
            .map { productsArrayResponse -> [CartMapper] in
                var updatedLineItems = cartMapper.itemsMapper
                
                for i in 0 ..< updatedLineItems.count {
                    let product = productsArrayResponse.first { product in
                        product.id == updatedLineItems[i].productId
                    }
                    let variant = product?.variants?.first { Variant in
                        Variant.id == updatedLineItems[i].variantId
                    }
                    updatedLineItems[i].itemImage = product?.image?.src ?? "unknown-Image-src"
                    updatedLineItems[i].currentInStock =
                    ((variant?.inventoryQuantity ?? 0) - updatedLineItems[i].quantity) > 0 ? (variant?.inventoryQuantity ?? 0) - updatedLineItems[i].quantity : 0
                }
                
                var udpatedCartMapper = cartMapper
                udpatedCartMapper.itemsMapper = updatedLineItems
                
                return [udpatedCartMapper]
            }
            .eraseToAnyPublisher()
    }
    
    func editDraftOrderAtPlacingOrder(_ draftOrder: DraftOrder) -> AnyPublisher<DraftOrder?, Error> {
        return remoteDataSource.editExistingDraftOrder(draftOrder: draftOrder)
    }
    
    func completeDraftOrder(withId id: Int) -> AnyPublisher<Void, Error> {
        return remoteDataSource.completeDraftOrder(id: id)
    }
    
    func deleteEntireDraftOrder(draftOrderID: Int64) -> AnyPublisher<Bool, Error> {
        return remoteDataSource.deleteExistingDraftOrder(draftOrderID: draftOrderID)
    }
    
    func getCustomerOrders(_ customerId: Int64) -> AnyPublisher<CustomerOrdersResponse?, any Error> {
        return remoteDataSource.getOrderForCustomer(customerId: customerId)
        
        func getAllDraftOrdersForCustomerByOrderID(orderID: Int64) -> AnyPublisher<[CartMapper], Error> {
            return remoteDataSource.fetchAllDraftOrders()
                .tryMap { DraftOrdersResponse -> [CartMapper] in
                    guard let draftOrders = DraftOrdersResponse?.draftOrders else {
                        return []
                    }
                    
                    let customerDraftOrder = draftOrders.filter { DraftOrder in
                        guard orderID == DraftOrder.id else {
                            return false
                        }
                        return true
                    }
                    
                    let cartMappers = customerDraftOrder.compactMap { draftOrder -> CartMapper? in
                        guard draftOrder.id != nil,
                              draftOrder.status != nil,
                              let lineItems = draftOrder.lineItems,
                              !lineItems.isEmpty else {
                            return nil
                        }
                        return CartMapper(draft: draftOrder)
                    }
                    return cartMappers
                }
                .eraseToAnyPublisher()
        }
        
    }
}
