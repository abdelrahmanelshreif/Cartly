struct SignUpData : Codable{
    let firstname:String
    let lastname:String?
    let email:String
    let password:String?
    let phone:String?
    let passwordConfirm:String?
    let sendinEmailVerification:Bool?
}


