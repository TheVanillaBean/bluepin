import UIKit
import SinchVerification;

class CountrySelectionViewController : UITableViewController {
    
    var isoCountryCode: String?
    
    var onCompletion: ((String) -> Void)?
    
    var entries: Array<SINRegionInfo> = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let regionList = PhoneNumberUtil().regionList(forLocale: NSLocale.currentLocale());
        entries = regionList.entries.sort({ (a: SINRegionInfo, b: SINRegionInfo) -> Bool in
            return a.countryDisplayName < b.countryDisplayName;
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        let row = entries.indexOf { (region: SINRegionInfo) -> Bool in
            return region.isoCountryCode == isoCountryCode;
        }
        if row != nil {
            tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: Int(row!), inSection: 0), animated: animated, scrollPosition: .Middle);
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("country", forIndexPath: indexPath);
        
        let entry = entries[indexPath.row];
        
        cell.textLabel?.text  = entry.countryDisplayName;
        cell.detailTextLabel?.text = String(format:"(+%@)", entry.countryCallingCode);
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        onCompletion?(entries[indexPath.row].isoCountryCode);
    }
    
}
