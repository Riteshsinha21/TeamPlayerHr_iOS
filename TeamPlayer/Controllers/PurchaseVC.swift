//
//  PurchaseVC.swift
//  TeamPlayer
//
//  Created by Ritesh Sinha on 04/08/21.
//

import UIKit
import Braintree
import BraintreeDropIn

class PurchaseVC: UIViewController {

    @IBOutlet weak var pptView: UIView!
    @IBOutlet weak var numberOfQuestionaireTxt: UITextField!
    
    var clientToken = String()
    var orderId = String()
    var braintreeClient: BTAPIClient?
    var totalAmount : Double = Double()
   // var totalAmount = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.getDemoPlanAPI()
        self.pptView.addLineDashedStroke(pattern: [2, 2], radius: 4, color: UIColor.gray.cgColor)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 6/255.0, green: 159/255.0, blue: 190/255.0, alpha: 1.0)
        
        self.tabBarController?.tabBar.standardAppearance = appearance;
        if #available(iOS 15.0, *) {
            self.tabBarController?.tabBar.scrollEdgeAppearance = self.tabBarController?.tabBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
//        self.getGroupList()
    }
    
    @IBAction func sideMenuAction(_ sender: Any) {
        openSideMenu()
    }
    
    @IBAction func notificationAction(_ sender: Any) {
    }
    
    @IBAction func paymentAction(_ sender: Any) {
        if self.numberOfQuestionaireTxt.text!.isEmpty {
            self.view.makeToast("Please fill the number of Questionaire you want.")
            return
        }
        self.totalAmount = self.totalAmount * Double(self.numberOfQuestionaireTxt.text!)!
        self.getBrainTreeToken()
    }
    
    func getDemoPlanAPI() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.DEMO_PLAN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    for i in 0..<json["data"].count {
                        if json["data"].count > 0 {
                            let amount =  json["data"][i]["amount"].stringValue
                            self.totalAmount = Double(amount) ?? 0.0
                            planId = json["data"][0]["id"].stringValue
                        }
                        
                     }
                    
                }
                else {
                    self.view.makeToast(json["message"].stringValue)
                   // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func updateDemoPaymentAPI() {
        
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = ["id": planId, "number_survay": self.numberOfQuestionaireTxt.text!, "data": []]
            print(param)
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.UPDATE_DEMO_PAYMENT, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
                    self.showAlert()
                }
                else {
                    self.view.makeToast(json["message"].stringValue)
                   // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Payment Done", message: "Please attend app questionaire.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in

            guard let window = UIApplication.shared.delegate?.window else {
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
            viewController.selectedIndex = 2
                                    
            window!.rootViewController = viewController
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.5
            UIView.transition(with: window!, duration: duration, options: options, animations: {}, completion:
                                { completed in
                window!.makeKeyAndVisible()
            })
            
        }))
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    func getBrainTreeToken() {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:String] = [:]
            ServerClass.sharedInstance.getRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.GET_BRAINTREE_TOKEN, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                var success = json["success"].stringValue
                success = "true"
                if success == "true"
                {
                    self.clientToken = json["token"].stringValue
//                    //print(self.clientToken)
                    self.braintreeClient = BTAPIClient(authorization: self.clientToken)
//
                    self.showDropIn(clientTokenOrTokenizationKey: self.clientToken)
                    
                } else {
                    UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.applePayDisabled = false // Make sure that  applePayDisabled is false
        
        let dropIn = BTDropInController.init(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                controller.dismiss(animated: true, completion: nil)
                print("CANCELLED")
                
            } else if let result = result{
                
                switch result.paymentOptionType {
                case .applePay ,.payPal,.masterCard,.discover,.visa:
                    // Here Result success  check paymentMethod not nil if nil then user select applePay
                    if let paymentMethod = result.paymentMethod{
                        //paymentMethod.nonce  You can use  nonce now
                        
                        let nonce = result.paymentMethod!.nonce
                        print( nonce)
                        //self.postNonceToServer(paymentMethodNonce: nonce, deviceData : self.deviceData)
                        self.autheticatePayment(paymentMethodNonce: nonce)
                        controller.dismiss(animated: true, completion: nil)
                    }else{
                        
                        controller.dismiss(animated: true, completion: {
                            
                            self.braintreeClient = BTAPIClient(authorization: clientTokenOrTokenizationKey)
                            
                            // call apple pay
                            let paymentRequest = self.paymentRequest()
                            
                            // Example: Promote PKPaymentAuthorizationViewController to optional so that we can verify
                            // that our paymentRequest is valid. Otherwise, an invalid paymentRequest would crash our app.
                            
                            if let vc = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                                as PKPaymentAuthorizationViewController?
                            {
                                vc.delegate = self
                                self.present(vc, animated: true, completion: nil)
                            } else {
                                print("Error: Payment request is invalid.")
                            }
                            
                        })
                        
                    }
                default:
                    print("error")
                    controller.dismiss(animated: true, completion: nil)
                }
                
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
            }
            
            
        }
        
        self.present(dropIn!, animated: true, completion: nil)
        
    }
    
    func autheticatePayment(paymentMethodNonce: String) {
        if Reachability.isConnectedToNetwork() {
            showProgressOnView(appDelegateInstance.window!)
            
            let param:[String:Any] = ["chargeAmount": "\(self.totalAmount)", "nonce": paymentMethodNonce]
            
            ServerClass.sharedInstance.postRequestWithUrlParameters(param, path: BASE_URL + PROJECT_URL.CREATE_PURCHASE, successBlock: { (json) in
                print(json)
                hideAllProgressOnView(appDelegateInstance.window!)
                let success = json["success"].stringValue
                if success == "true"
                {
                    
//                    self.view.makeToast("Payment done successfully.")
                    self.updateDemoPaymentAPI()
                    
                }
                else {
                    self.view.makeToast("\(json["message"].stringValue)")
                    // UIAlertController.showInfoAlertWithTitle("Message", message: json["message"].stringValue, buttonTitle: "Okay")
                }
            }, errorBlock: { (NSError) in
                UIAlertController.showInfoAlertWithTitle("Alert", message: kUnexpectedErrorAlertString, buttonTitle: "Okay")
                hideAllProgressOnView(appDelegateInstance.window!)
            })
            
        }else{
            hideAllProgressOnView(appDelegateInstance.window!)
            UIAlertController.showInfoAlertWithTitle("Alert", message: "Please Check internet connection", buttonTitle: "Okay")
        }
    }
    
}

extension PurchaseVC : PKPaymentAuthorizationViewControllerDelegate{
    
    func paymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        //paymentRequest.merchantIdentifier = "merchant.wuber1";
        paymentRequest.merchantIdentifier = "y7sk7rb548cyt9qy";
        paymentRequest.supportedNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.visa, PKPaymentNetwork.masterCard];
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS;
        paymentRequest.countryCode = "US"; // e.g. US
        paymentRequest.currencyCode = "USD"; // e.g. USD
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Merchant", amount: 1.0),
            
        ]
        return paymentRequest
    }
    
    
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Swift.Void){
        
        // Example: Tokenize the Apple Pay payment
        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        applePayClient.tokenizeApplePay(payment) {
            (tokenizedApplePayPayment, error) in
            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                // Tokenization failed. Check `error` for the cause of the failure.
                
                // Indicate failure via completion callback.
                completion(PKPaymentAuthorizationStatus.failure)
                
                return
            }
            
            // Received a tokenized Apple Pay payment from Braintree.
            // If applicable, address information is accessible in `payment`.
            
            // Send the nonce to your server for processing.
            print("nonce = \(tokenizedApplePayPayment.nonce)")
            
            //self.postNonceToServer(paymentMethodNonce: tokenizedApplePayPayment.nonce, deviceData: self.deviceData)
            self.autheticatePayment(paymentMethodNonce: tokenizedApplePayPayment.nonce)
            // Then indicate success or failure via the completion callback, e.g.
            completion(PKPaymentAuthorizationStatus.success)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
