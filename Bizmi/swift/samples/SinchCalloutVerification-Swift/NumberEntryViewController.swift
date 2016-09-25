import UIKit;
import SinchVerification;

func PhoneNumberUtil() -> PhoneNumberUtil {
    return SharedPhoneNumberUtil();
}

class NumberEntryViewController: UIViewController {
    
    @IBOutlet var countryButton: UIButton!
    @IBOutlet var numberTextField: UITextField!
    @IBOutlet var verifyButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var isoCountryCode: String!
    var formatter: TextFieldPhoneNumberFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.isoCountryCode = DeviceRegion.currentCountryCode();
        
        self.formatter = TextFieldPhoneNumberFormatter(countryCode: isoCountryCode);
        formatter.textField = numberTextField;
        formatter.onTextFieldTextDidChange = { (textField: UITextField) -> Void in
            self.onTextFieldTextDidChange(textField);
        }
        
        updateFormatter();
        updateCountrySelection();
        
        initAppearance(self);
    }
    
    func updateFormatter() {
        formatter.countryCode = isoCountryCode;
        numberTextField.placeholder = formatter.exampleNumber(format:PhoneNumberFormat.National)
    }
    
    func updateCountrySelection() {
        let regions = PhoneNumberUtil().regionList(forLocale: NSLocale.currentLocale());
        let displayName = regions.displayNameForRegion(isoCountryCode);
        let callingCode = regions.countryCallingCodeForRegion(isoCountryCode);
        countryButton.setTitle(String(format:"(+%@) %@", callingCode!, displayName), forState: .Normal);
    }
    
    func onTextFieldTextDidChange(textField: UITextField) {
        let update = {(enabled: Bool, color:UIColor) -> Void in
            self.verifyButton.enabled = enabled;
            self.numberTextField.backgroundColor = color;
        }
        
        let text = textField.text != nil ? textField.text! : "";
        let isPossibleNumber = PhoneNumberUtil().isPossibleNumber(text, fromRegion: isoCountryCode);

        if (textField.text!.isEmpty) {
            update(false, UIColor.clearColor());
        } else if (isPossibleNumber.possible){
            update(true, colorForPossiblePhoneNumber());
        } else {
            update(false, colorForNotPossiblePhoneNumber());
            print(isPossibleNumber.error!);
        }
        
    }
    
    @IBAction
    func verify(sender:AnyObject?) {
        sender?.resignFirstResponder();
        
        let text = numberTextField.text != nil ? numberTextField.text! : "";
        
        do {
            let phoneNumber = try PhoneNumberUtil().parse(text, defaultRegion:isoCountryCode);
            
            let phoneNumberE164 = PhoneNumberUtil().format(phoneNumber, format: PhoneNumberFormat.E164);
            
            let verification = CalloutVerification(applicationKey:"<APP KEY>", phoneNumber: phoneNumberE164);
            
            verification.initiate({ (success: Bool, error: NSError?) -> Void in
                if(success){
                    self.setStatusText("Verification Successful");
                } else {
                    self.setStatusText("Verification Failed");
                    showError(error!);
                }
            });
            
        } catch let error as PhoneNumberParseError {
            showError("Invalid phone number: " + String(error));
        } catch {
            print(error);
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let controller = segue.destinationViewController as? CountrySelectionViewController {
            controller.isoCountryCode = isoCountryCode;
            controller.onCompletion = {(selectedCountryCode: String) -> Void in
                controller.dismissViewControllerAnimated(true, completion: nil);
                self.isoCountryCode = selectedCountryCode;
                self.updateCountrySelection();
                self.updateFormatter();
            }
        }
    }
    
    func setStatusText(text:String) {
        statusLabel.text = text;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        numberTextField.becomeFirstResponder();
    }
    
}
