import Foundation
import UIKit
import WebKit

let titleBarColorcnentt:UIColor = .white
let bottomBarColorcnentt:UIColor = .white
let titleFontcnentt:UIFont = UIFont.boldSystemFont(ofSize: CGFloat(18))
let titleTextColorcnentt:UIColor = .black
let windowMaskColorcnentt:UIColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
let btnBackgroundColorcnentt:UIColor = .white
let btnOnLineColorcnentt:UIColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.68)
//let btnOnLineColorcnentt:UIColor = .init(red: 230/255, green: 57/255, blue: 70/255, alpha: 1.0)
let btnOffLineColorcnentt:UIColor = .lightGray

class MultiLoadWebViewControllercnentt: UIViewController, WKNavigationDelegate {
    
    var wkWebViewcnentt:WKWebView!
    var backBtncnentt:UIButton!
    var forwardBtncnentt:UIButton!
    var titleDesccnentt:String = " "
    var isInitcnentt = false
    var multiUrlcnentt:[String] = [String]()
    var backUrlcnentt:String?
    var callbackcnentt: (() -> Void)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(titlecnentt:String, urlscnentt:[String]?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        titleDesccnentt = titlecnentt
        if (urlscnentt != nil) {
            multiUrlcnentt = urlscnentt!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.view.addSubview(mainViewcnentt)
        mainViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        mainViewcnentt.backgroundColor = windowMaskColorcnentt
        
        let leftViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(leftViewcnentt)
        leftViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        leftViewcnentt.backgroundColor = UIColor.clear
        
        let rightViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(rightViewcnentt)
        rightViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        rightViewcnentt.backgroundColor = UIColor.clear
        
        let topViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(topViewcnentt)
        topViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        topViewcnentt.backgroundColor = UIColor.clear
        
        let bottmViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(bottmViewcnentt)
        bottmViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        bottmViewcnentt.backgroundColor = UIColor.clear
        
        let titleViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(titleViewcnentt)
        titleViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        titleViewcnentt.clipsToBounds = true
        titleViewcnentt.backgroundColor = titleBarColorcnentt
        
        let toolsViewcnentt = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(toolsViewcnentt)
        toolsViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        toolsViewcnentt.backgroundColor = bottomBarColorcnentt
        
        wkWebViewcnentt = WKWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        mainViewcnentt.addSubview(wkWebViewcnentt)
        wkWebViewcnentt.translatesAutoresizingMaskIntoConstraints = false
        wkWebViewcnentt.backgroundColor = UIColor.groupTableViewBackground
        
        let titleLabelcnentt = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        titleViewcnentt.addSubview(titleLabelcnentt)
        titleLabelcnentt.translatesAutoresizingMaskIntoConstraints = false
        titleLabelcnentt.numberOfLines = 1
        titleLabelcnentt.backgroundColor = UIColor.clear
        titleLabelcnentt.font = titleFontcnentt
        titleLabelcnentt.textAlignment = NSTextAlignment.center
        
        let homeBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(homeBtncnentt)
        homeBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        homeBtncnentt.backgroundColor = btnBackgroundColorcnentt
        
        homeBtncnentt.imageView?.contentMode = .scaleAspectFit
        homeBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        homeBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.horizontal)
        homeBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.vertical)
        homeBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        homeBtncnentt.imageView?.contentMode = .scaleAspectFit
        homeBtncnentt.setImage(getNaviHomeLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        homeBtncnentt.setImage(getNaviHomeLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        backBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(backBtncnentt)
        backBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        backBtncnentt.backgroundColor = btnBackgroundColorcnentt
        
        backBtncnentt.imageView?.contentMode = .scaleAspectFit
        backBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        backBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.horizontal)
        backBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.vertical)
        backBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        backBtncnentt.imageView?.contentMode = .scaleAspectFit
        backBtncnentt.setImage(getNaviBackLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        backBtncnentt.setImage(getNaviBackLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        forwardBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(forwardBtncnentt)
        forwardBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        forwardBtncnentt.backgroundColor = btnBackgroundColorcnentt
        
        forwardBtncnentt.imageView?.contentMode = .scaleAspectFit
        forwardBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        forwardBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.horizontal)
        forwardBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.vertical)
        forwardBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        forwardBtncnentt.imageView?.contentMode = .scaleAspectFit
        forwardBtncnentt.setImage(getNaviForwardLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        forwardBtncnentt.setImage(getNaviForwardLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        
        let refreshBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(refreshBtncnentt)
        refreshBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        refreshBtncnentt.backgroundColor = btnBackgroundColorcnentt
        
        refreshBtncnentt.imageView?.contentMode = .scaleAspectFit
        refreshBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        refreshBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.horizontal)
        refreshBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.vertical)
        refreshBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        refreshBtncnentt.imageView?.contentMode = .scaleAspectFit
        refreshBtncnentt.setImage(getNaviRefreshLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        refreshBtncnentt.setImage(getNaviRefreshLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        
        let exitBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(exitBtncnentt)
        exitBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        exitBtncnentt.backgroundColor = btnBackgroundColorcnentt
        
        exitBtncnentt.imageView?.contentMode = .scaleAspectFit
        exitBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.vertical)
        exitBtncnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 100), for: NSLayoutConstraint.Axis.horizontal)
        exitBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.vertical)
        exitBtncnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        exitBtncnentt.imageView?.contentMode = .scaleAspectFit
        exitBtncnentt.setImage(getNaviExitLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        exitBtncnentt.setImage(getNaviExitLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        let linview = UIView()
        linview.backgroundColor = .lightGray
        toolsViewcnentt.addSubview(linview)
        linview.translatesAutoresizingMaskIntoConstraints = false
        linview.topAnchor.constraint(equalTo: toolsViewcnentt.topAnchor).isActive = true
        linview.leadingAnchor.constraint(equalTo: toolsViewcnentt.leadingAnchor).isActive = true
        linview.trailingAnchor.constraint(equalTo: toolsViewcnentt.trailingAnchor).isActive = true
        linview.bottomAnchor.constraint(equalTo: toolsViewcnentt.topAnchor, constant: 0.3).isActive = true
        
        let closeBtncnentt = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        toolsViewcnentt.addSubview(closeBtncnentt)
        closeBtncnentt.translatesAutoresizingMaskIntoConstraints = false
        closeBtncnentt.backgroundColor = titleBarColorcnentt
        closeBtncnentt.imageView?.contentMode = .scaleAspectFit
        closeBtncnentt.setImage(getNaviExitLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: titleTextColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
        closeBtncnentt.setImage(getNaviExitLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.highlighted)
        
        let titleLabelHeightcnentt = NSLayoutConstraint(item: titleLabelcnentt,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: 21.0)
        titleLabelHeightcnentt.priority = UILayoutPriority(rawValue: 249)
        titleLabelcnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: NSLayoutConstraint.Axis.vertical)
        titleLabelcnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: NSLayoutConstraint.Axis.vertical)
        
        titleLabelcnentt.setContentHuggingPriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        titleLabelcnentt.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 50), for: NSLayoutConstraint.Axis.horizontal)
        
        titleLabelcnentt.addConstraint(titleLabelHeightcnentt)
        
        
        titleViewcnentt.addConstraints([NSLayoutConstraint(item: titleLabelcnentt,
                                                           attribute: NSLayoutConstraint.Attribute.centerY,
                                                           relatedBy: .equal,
                                                           toItem: titleViewcnentt,
                                                           attribute: .centerY,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: titleLabelcnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: titleViewcnentt,
                                                           attribute: .trailing,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: titleLabelcnentt,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: titleViewcnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: titleLabelcnentt,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: titleViewcnentt,
                                                           attribute: .height,
                                                           multiplier: 0.5,
                                                           constant: 0.0)])
        
        self.view.addConstraints([NSLayoutConstraint(item: mainViewcnentt,
                                                     attribute: .leading,
                                                     relatedBy: .equal,
                                                     toItem: self.view,
                                                     attribute: .leading,
                                                     multiplier: 1.0,
                                                     constant: 0.0),
                                  NSLayoutConstraint(item: mainViewcnentt,
                                                     attribute: .top,
                                                     relatedBy: .equal,
                                                     toItem: self.topLayoutGuide,
                                                     attribute: .bottom,
                                                     multiplier: 1.0,
                                                     constant: 0.0),
                                  NSLayoutConstraint(item: mainViewcnentt,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self.view,
                                                     attribute: .trailing,
                                                     multiplier: 1.0,
                                                     constant: 0.0),
                                  NSLayoutConstraint(item: mainViewcnentt,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: self.bottomLayoutGuide,
                                                     attribute: .top,
                                                     multiplier: 1.0,
                                                     constant: 0.0)])
        
        mainViewcnentt.addConstraints([NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: bottmViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: toolsViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: wkWebViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: titleViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: topViewcnentt,
                                                          attribute: .leading,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: leftViewcnentt, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: titleViewcnentt, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.5, constant: 0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .trailing,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: bottmViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: topViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: toolsViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: titleViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: wkWebViewcnentt,
                                                          attribute: .trailing,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: rightViewcnentt, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: titleViewcnentt, attribute: NSLayoutConstraint.Attribute.height, multiplier: 0.5, constant: 0),
                                       NSLayoutConstraint(item: topViewcnentt,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: topViewcnentt,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: titleViewcnentt,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: topViewcnentt, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: titleViewcnentt, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.5, constant: 0),
                                       NSLayoutConstraint(item: bottmViewcnentt,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: mainViewcnentt,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: bottmViewcnentt,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: toolsViewcnentt,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: bottmViewcnentt, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: titleViewcnentt, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.5, constant: 0),
                                       NSLayoutConstraint(item: titleViewcnentt,
                                                          attribute: .bottom,
                                                          relatedBy: .equal,
                                                          toItem: wkWebViewcnentt,
                                                          attribute: .top,
                                                          multiplier: 1.0,
                                                          constant: 0.0),
                                       NSLayoutConstraint(item: toolsViewcnentt,
                                                          attribute: .top,
                                                          relatedBy: .equal,
                                                          toItem: wkWebViewcnentt,
                                                          attribute: .bottom,
                                                          multiplier: 1.0,
                                                          constant: 0.0)])
        
        
        
        toolsViewcnentt.addConstraints([NSLayoutConstraint(item: closeBtncnentt,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: closeBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: closeBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .trailing,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: closeBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: toolsViewcnentt,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1.0,
                                                           constant: 44.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .leading,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: backBtncnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: backBtncnentt,
                                                           attribute: .width,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: forwardBtncnentt,
                                                           attribute: .width,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: refreshBtncnentt,
                                                           attribute: .width,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: homeBtncnentt,
                                                           attribute: .width,
                                                           relatedBy: .equal,
                                                           toItem: exitBtncnentt,
                                                           attribute: .width,
                                                           multiplier: 1.0,
                                                           constant: 0.0),
                                        NSLayoutConstraint(item: backBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: backBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: backBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: forwardBtncnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: forwardBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: forwardBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: forwardBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: refreshBtncnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: refreshBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: refreshBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: refreshBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: exitBtncnentt,
                                                           attribute: .leading,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: exitBtncnentt,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .bottom,
                                                           multiplier: 1.0,
                                                           constant: -5.0),
                                        NSLayoutConstraint(item: exitBtncnentt,
                                                           attribute: .top,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .top,
                                                           multiplier: 1.0,
                                                           constant: 5.0),
                                        NSLayoutConstraint(item: exitBtncnentt,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: toolsViewcnentt,
                                                           attribute: .trailing,
                                                           multiplier: 1.0,
                                                           constant: -5.0)])
        
        self.view.layoutIfNeeded()
        
        titleViewcnentt.backgroundColor = titleBarColorcnentt
        titleLabelcnentt.textColor = titleTextColorcnentt
        toolsViewcnentt.backgroundColor = bottomBarColorcnentt
        homeBtncnentt.backgroundColor = btnBackgroundColorcnentt
        backBtncnentt.backgroundColor = btnBackgroundColorcnentt
        forwardBtncnentt.backgroundColor = btnBackgroundColorcnentt
        refreshBtncnentt.backgroundColor = btnBackgroundColorcnentt
        exitBtncnentt.backgroundColor = btnBackgroundColorcnentt
        closeBtncnentt.backgroundColor = titleBarColorcnentt
        
        titleLabelcnentt.text = titleDesccnentt
        if (titleLabelcnentt.text!.count > 0) {
            toolsViewcnentt.backgroundColor = titleBarColorcnentt
            closeBtncnentt.isHidden = false
        } else {
            toolsViewcnentt.backgroundColor = bottomBarColorcnentt
            closeBtncnentt.isHidden = true
        }
        wkWebViewcnentt.navigationDelegate = self
        
        homeBtncnentt.addTarget(self, action: #selector(homeBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        forwardBtncnentt.addTarget(self, action: #selector(forwardBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        backBtncnentt.addTarget(self, action: #selector(backBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        refreshBtncnentt.addTarget(self, action: #selector(refreshBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        exitBtncnentt.addTarget(self, action: #selector(exitBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        closeBtncnentt.addTarget(self, action: #selector(closeBtnClickcnentt(sender:)), for: UIControl.Event.touchUpInside)
        
        resetBtnColorcnentt(cnenttx: nil, cnentty: nil, cnenttz: nil)
        
        if (multiUrlcnentt.count > 0) {
            isInitcnentt = true
            while (multiUrlcnentt.count > 0) {
                if let gotoUrlcnentt:URL = URL(string: multiUrlcnentt[0]) {
                    let requestcnentt:URLRequest = URLRequest(url: gotoUrlcnentt)
                    self.multiUrlcnentt.removeFirst()
                    self.wkWebViewcnentt.load(requestcnentt)
                    break
                } else {
                    self.multiUrlcnentt.removeFirst()
                    if (self.multiUrlcnentt.count == 0) {
                        isInitcnentt = false
                    }
                }
            }
        }
        
    }
    
    func setCallbackcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, callbackHandlercnentt: (() -> Void)?) {
        callbackcnentt = callbackHandlercnentt
    }
    
    func loadMulticnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, urlscnentt:[String]) {
        multiUrlcnentt = urlscnentt
        if (multiUrlcnentt.count > 0) {
            while (multiUrlcnentt.count > 0) {
                if let gotoUrlcnentt:URL = URL(string: multiUrlcnentt[0]) {
                    let requestcnentt:URLRequest = URLRequest(url: gotoUrlcnentt)
                    self.multiUrlcnentt.removeFirst()
                    self.wkWebViewcnentt.load(requestcnentt)
                    break
                } else {
                    self.multiUrlcnentt.removeFirst()
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        self.resetBtnColorcnentt(cnenttx: nil, cnentty: nil, cnenttz: nil)
        
        if let urlcnentt = navigationAction.request.url {
            
            let htcnentt:[Character] = ["h", "-", "t", "-", "t", "-", "p", "-", ":", "-", "/", "-", "/"]
            let htscnentt:[Character] = ["h", "-", "t", "-", "t", "-", "p", "-", "s", "-", ":", "-", "/", "-", "/"]
            let ftcnentt:[Character] = ["f", "-", "t", "-", "p", "-", ":", "-", "/", "-", "/"]
            
            if (!(urlcnentt.absoluteString.hasPrefix(String(htcnentt).replacingOccurrences(of: "-", with: "")) || urlcnentt.absoluteString.hasPrefix(String(htscnentt).replacingOccurrences(of: "-", with: "")) || urlcnentt.absoluteString.hasPrefix(String(ftcnentt).replacingOccurrences(of: "-", with: "")))) {
                
                decisionHandler(WKNavigationActionPolicy.cancel)
                
                if (self.wkWebViewcnentt.backForwardList.backList.count > 0) {
                    backUrlcnentt = self.wkWebViewcnentt.backForwardList.backList[self.wkWebViewcnentt.backForwardList.backList.count - 1].url.absoluteString
                } else {
                    backUrlcnentt = nil
                }
                
                UIApplication.shared.open(urlcnentt, options: [:], completionHandler: nil)
                return
                
            }
            
        }
        backUrlcnentt = nil
        decisionHandler(.allow)
        
        return
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.resetBtnColorcnentt(cnenttx: nil, cnentty: nil, cnenttz: nil)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.resetBtnColorcnentt(cnenttx: nil, cnentty: nil, cnenttz: nil)
        if (isInitcnentt) {
            if (multiUrlcnentt.count > 0) {
                while (multiUrlcnentt.count > 0) {
                    if let gotoUrlcnentt:URL = URL(string: multiUrlcnentt[0]) {
                        let requestcnentt:URLRequest = URLRequest(url: gotoUrlcnentt)
                        self.multiUrlcnentt.removeFirst()
                        self.wkWebViewcnentt.load(requestcnentt)
                        break
                    } else {
                        self.multiUrlcnentt.removeFirst()
                        if (self.multiUrlcnentt.count == 0) {
                            isInitcnentt = false
                        }
                    }
                }
            } else {
                isInitcnentt = false
            }
        } else {
            if (multiUrlcnentt.count > 0) {
                while (multiUrlcnentt.count > 0) {
                    if let gotoUrlcnentt:URL = URL(string: multiUrlcnentt[0]) {
                        let requestcnentt:URLRequest = URLRequest(url: gotoUrlcnentt)
                        self.multiUrlcnentt.removeFirst()
                        self.wkWebViewcnentt.load(requestcnentt)
                        break
                    } else {
                        self.multiUrlcnentt.removeFirst()
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.resetBtnColorcnentt(cnenttx: nil, cnentty: nil, cnenttz: nil)
    }
    
    func resetBtnColorcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?) {
        
        DispatchQueue.main.async {
            
            if (self.wkWebViewcnentt.canGoBack) {
                self.backBtncnentt.setImage(getNaviBackLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
            } else {
                self.backBtncnentt.setImage(getNaviBackLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
            }
            
            if (self.wkWebViewcnentt.canGoForward) {
                self.forwardBtncnentt.setImage(getNaviForwardLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOnLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
            } else {
                self.forwardBtncnentt.setImage(getNaviForwardLineImagecnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, imageSizecnentt: 100, arrowStrokeWidthcnentt: 8, arrowColorcnentt: btnOffLineColorcnentt, backgroundColorcnentt: .clear), for: UIControl.State.normal)
            }
            
        }
        
    }
    
    @objc func homeBtnClickcnentt(sender: UIButton) {
        if (self.wkWebViewcnentt.canGoBack) {
            self.wkWebViewcnentt.load(URLRequest(url: self.wkWebViewcnentt.backForwardList.backList[0].url))
        }
    }
    
    @objc func backBtnClickcnentt(sender: UIButton) {
        if (self.titleDesccnentt.count > 0) {
            if (self.wkWebViewcnentt.canGoBack) {
                self.wkWebViewcnentt.goBack()
            } else {
                self.dismiss(animated: true) {
                    if (self.callbackcnentt != nil) {
                        self.callbackcnentt!()
                    }
                }
            }
        } else {
            
            if (self.wkWebViewcnentt.canGoBack) {
                if (backUrlcnentt != nil) {
                    var lastIndexcnentt = self.wkWebViewcnentt.backForwardList.backList.count - 1
                    for i in 0..<self.wkWebViewcnentt.backForwardList.backList.count {
                        if (self.wkWebViewcnentt.backForwardList.backList[self.wkWebViewcnentt.backForwardList.backList.count - i - 1].url.absoluteString == backUrlcnentt!) {
                            lastIndexcnentt = self.wkWebViewcnentt.backForwardList.backList.count - i - 1
                            break
                        }
                    }
                    self.wkWebViewcnentt.go(to: self.wkWebViewcnentt.backForwardList.backList[lastIndexcnentt])
                } else {
                    self.wkWebViewcnentt.goBack()
                }
            }
        }
    }
    
    @objc func forwardBtnClickcnentt(sender: UIButton) {
        if (self.wkWebViewcnentt.canGoForward) {
            self.wkWebViewcnentt.goForward()
        }
    }
    
    @objc func refreshBtnClickcnentt(sender: UIButton) {
        self.wkWebViewcnentt.reload()
    }
    
    @objc func exitBtnClickcnentt(sender: UIButton) {
        if (self.titleDesccnentt.count > 0) {
            self.dismiss(animated: true) {
                if (self.callbackcnentt != nil) {
                    self.callbackcnentt!()
                }
            }
        } else {
            exit(0)
        }
    }
    
    @objc func closeBtnClickcnentt(sender: UIButton) {
        self.dismiss(animated: true) {
            if (self.callbackcnentt != nil) {
                self.callbackcnentt!()
            }
        }
    }
    
}

func radiansToDegreescnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, radianscnentt:CGFloat) -> CGFloat {
    //
    // 弧度轉成角度
    return radianscnentt * 180 / CGFloat.pi
}
func degreesToRadianscnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, degreescnentt:CGFloat) -> CGFloat {
    //
    // 角度轉成弧度
    return degreescnentt * CGFloat.pi / 180
}

func getXrightPlusByRadiuscnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    return lengthcnentt * cos(degreesRightcnentt * CGFloat.pi / 180)
}

func getYtopPlusByRadiuscnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    return lengthcnentt * sin(degreesRightcnentt * CGFloat.pi / 180)
}

func getSideLengthByXcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    let yLencnentt = lengthcnentt * tan(degreesRightcnentt * CGFloat.pi / 180)
    return sqrt(lengthcnentt*lengthcnentt + yLencnentt*yLencnentt)
}

func getSideLengthByYcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    let xLencnentt = lengthcnentt / tan(degreesRightcnentt * CGFloat.pi / 180)
    return sqrt(lengthcnentt*lengthcnentt + xLencnentt*xLencnentt)
}

func getYtopPlusByXcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    return lengthcnentt * tan(degreesRightcnentt * CGFloat.pi / 180)
}

func getXrightPlusByYcnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, lengthcnentt:CGFloat, degreesRightcnentt:CGFloat) -> CGFloat {
    //
    // 中心向右為0度，逆時針旋轉，X左為正Y上為正
    return lengthcnentt / tan(degreesRightcnentt * CGFloat.pi / 180)
}

func imageToBase64cnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imagecnentt:UIImage) -> String {
    //
    // 將圖片轉為 base64 字串
    if let imageDatacnentt = imagecnentt.pngData() {
        return imageDatacnentt.base64EncodedString()
    } else {
        if let imageDatacnentt = imagecnentt.jpegData(compressionQuality: 0.75) {
            return imageDatacnentt.base64EncodedString()
        } else {
            return ""
        }
    }
}

func base64ToImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, base64cnentt:String) -> UIImage? {
    
    if let dataDecodedcnentt = Data(base64Encoded: base64cnentt, options: Data.Base64DecodingOptions.init()) {
        if let decodedimagecnentt = UIImage(data: dataDecodedcnentt) {
            return decodedimagecnentt
        }
    }
    
    return nil
}

func getNaviHomeLineImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imageSizecnentt:CGFloat?, arrowStrokeWidthcnentt:CGFloat?, arrowColorcnentt:UIColor?, backgroundColorcnentt:UIColor?) -> UIImage? {
    
    var contextSizecnentt:CGFloat = 100
    if (imageSizecnentt != nil) {
        contextSizecnentt = imageSizecnentt!
    }
    let sideLangthcnentt:CGFloat = contextSizecnentt * 0.8
    var strokeWidthcnentt:CGFloat = 4
    if (arrowStrokeWidthcnentt != nil) {
        strokeWidthcnentt = arrowStrokeWidthcnentt!
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: contextSizecnentt, height: contextSizecnentt), false, 0.0)
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        
        contextcnentt.beginPath()
        contextcnentt.move(to: CGPoint(x: 0, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: contextSizecnentt))
        contextcnentt.addLine(to: CGPoint(x: 0, y: contextSizecnentt))
        contextcnentt.closePath()
        if let colorcnentt = backgroundColorcnentt {
            contextcnentt.setFillColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setFillColor(UIColor.clear.cgColor)
        }
        contextcnentt.fillPath()
    }
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        contextcnentt.beginPath()
        contextcnentt.setLineCap(.round)
        contextcnentt.setLineJoin(.round)
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 , y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0))
        
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2, y: contextSizecnentt * 0.1))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.85, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.85, y: contextSizecnentt * 0.1 + sideLangthcnentt))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7, y: contextSizecnentt * 0.1 + sideLangthcnentt))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3, y: contextSizecnentt * 0.1 + sideLangthcnentt))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.15, y: contextSizecnentt * 0.1 + sideLangthcnentt))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.15, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0))
        
        contextcnentt.setLineWidth(strokeWidthcnentt)
        if let colorcnentt = arrowColorcnentt {
            contextcnentt.setStrokeColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setStrokeColor(UIColor.clear.cgColor)
        }
        contextcnentt.strokePath()
    }
    
    let imgcnentt = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imgcnentt
}

func getNaviBackLineImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imageSizecnentt:CGFloat?, arrowStrokeWidthcnentt:CGFloat?, arrowColorcnentt:UIColor?, backgroundColorcnentt:UIColor?) -> UIImage? {
    
    var contextSizecnentt:CGFloat = 100
    if (imageSizecnentt != nil) {
        contextSizecnentt = imageSizecnentt!
    }
    let sideLangthcnentt:CGFloat = contextSizecnentt * 0.8
    var strokeWidthcnentt:CGFloat = 4
    if (arrowStrokeWidthcnentt != nil) {
        strokeWidthcnentt = arrowStrokeWidthcnentt!
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: contextSizecnentt, height: contextSizecnentt), false, 0.0)
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        
        contextcnentt.beginPath()
        contextcnentt.move(to: CGPoint(x: 0, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: contextSizecnentt))
        contextcnentt.addLine(to: CGPoint(x: 0, y: contextSizecnentt))
        contextcnentt.closePath()
        if let colorcnentt = backgroundColorcnentt {
            contextcnentt.setFillColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setFillColor(UIColor.clear.cgColor)
        }
        contextcnentt.fillPath()
    }
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        contextcnentt.beginPath()
        contextcnentt.setLineCap(.round)
        contextcnentt.setLineJoin(.round)
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.9))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.5))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.1))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        
        contextcnentt.setLineWidth(strokeWidthcnentt)
        if let colorcnentt = arrowColorcnentt {
            contextcnentt.setStrokeColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setStrokeColor(UIColor.clear.cgColor)
        }
        contextcnentt.strokePath()
    }
    
    let imgcnentt = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imgcnentt
}

func getNaviForwardLineImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imageSizecnentt:CGFloat?, arrowStrokeWidthcnentt:CGFloat?, arrowColorcnentt:UIColor?, backgroundColorcnentt:UIColor?) -> UIImage? {
    
    var contextSizecnentt:CGFloat = 100
    if (imageSizecnentt != nil) {
        contextSizecnentt = imageSizecnentt!
    }
    let sideLangthcnentt:CGFloat = contextSizecnentt * 0.8
    var strokeWidthcnentt:CGFloat = 4
    if (arrowStrokeWidthcnentt != nil) {
        strokeWidthcnentt = arrowStrokeWidthcnentt!
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: contextSizecnentt, height: contextSizecnentt), false, 0.0)
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        
        contextcnentt.beginPath()
        contextcnentt.move(to: CGPoint(x: 0, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: contextSizecnentt))
        contextcnentt.addLine(to: CGPoint(x: 0, y: contextSizecnentt))
        contextcnentt.closePath()
        if let colorcnentt = backgroundColorcnentt {
            contextcnentt.setFillColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setFillColor(UIColor.clear.cgColor)
        }
        contextcnentt.fillPath()
    }
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        contextcnentt.beginPath()
        contextcnentt.setLineCap(.round)
        contextcnentt.setLineJoin(.round)
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.9))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.5))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.1))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.3))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.7))
        
        contextcnentt.setLineWidth(strokeWidthcnentt)
        if let colorcnentt = arrowColorcnentt {
            contextcnentt.setStrokeColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setStrokeColor(UIColor.clear.cgColor)
        }
        contextcnentt.strokePath()
    }
    
    let imgcnentt = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imgcnentt
}

func getNaviRefreshLineImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imageSizecnentt:CGFloat?, arrowStrokeWidthcnentt:CGFloat?, arrowColorcnentt:UIColor?, backgroundColorcnentt:UIColor?) -> UIImage? {
    
    var contextSizecnentt:CGFloat = 100
    if (imageSizecnentt != nil) {
        contextSizecnentt = imageSizecnentt!
    }
    let sideLangthcnentt:CGFloat = contextSizecnentt * 0.8
    var strokeWidthcnentt:CGFloat = 4
    if (arrowStrokeWidthcnentt != nil) {
        strokeWidthcnentt = arrowStrokeWidthcnentt!
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: contextSizecnentt, height: contextSizecnentt), false, 0.0)
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        
        contextcnentt.beginPath()
        contextcnentt.move(to: CGPoint(x: 0, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: contextSizecnentt))
        contextcnentt.addLine(to: CGPoint(x: 0, y: contextSizecnentt))
        contextcnentt.closePath()
        if let colorcnentt = backgroundColorcnentt {
            contextcnentt.setFillColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setFillColor(UIColor.clear.cgColor)
        }
        contextcnentt.fillPath()
    }
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        contextcnentt.beginPath()
        contextcnentt.setLineCap(.round)
        contextcnentt.setLineJoin(.round)
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 + getXrightPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 150), y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 - getYtopPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 150)))
        contextcnentt.addArc(center: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0), radius: sideLangthcnentt * 0.4, startAngle: 210 * CGFloat.pi / 180 , endAngle: 0, clockwise: false)
        
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.8, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.9, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.5))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4))
        
        
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 + getXrightPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 330), y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 - getYtopPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 330)))
        contextcnentt.addArc(center: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0), radius: sideLangthcnentt * 0.4, startAngle: 30 * CGFloat.pi / 180 , endAngle: 180 * CGFloat.pi / 180, clockwise: false)
        
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.2, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt * 0.1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.5))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.6))
        
        contextcnentt.setLineWidth(strokeWidthcnentt)
        if let colorcnentt = arrowColorcnentt {
            contextcnentt.setStrokeColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setStrokeColor(UIColor.clear.cgColor)
        }
        contextcnentt.strokePath()
    }
    
    let imgcnentt = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imgcnentt
}

func getNaviExitLineImagecnentt(cnenttx: String?, cnentty: String?, cnenttz: String?, imageSizecnentt:CGFloat?, arrowStrokeWidthcnentt:CGFloat?, arrowColorcnentt:UIColor?, backgroundColorcnentt:UIColor?) -> UIImage? {
    
    var contextSizecnentt:CGFloat = 100
    if (imageSizecnentt != nil) {
        contextSizecnentt = imageSizecnentt!
    }
    let sideLangthcnentt:CGFloat = contextSizecnentt * 0.8
    var strokeWidthcnentt:CGFloat = 4
    if (arrowStrokeWidthcnentt != nil) {
        strokeWidthcnentt = arrowStrokeWidthcnentt!
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: contextSizecnentt, height: contextSizecnentt), false, 0.0)
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        
        contextcnentt.beginPath()
        contextcnentt.move(to: CGPoint(x: 0, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: 0))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt, y: contextSizecnentt))
        contextcnentt.addLine(to: CGPoint(x: 0, y: contextSizecnentt))
        contextcnentt.closePath()
        if let colorcnentt = backgroundColorcnentt {
            contextcnentt.setFillColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setFillColor(UIColor.clear.cgColor)
        }
        contextcnentt.fillPath()
    }
    
    if let contextcnentt = UIGraphicsGetCurrentContext() {
        contextcnentt.beginPath()
        contextcnentt.setLineCap(.round)
        contextcnentt.setLineJoin(.round)
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 + getXrightPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 120), y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0 - getYtopPlusByRadiuscnentt(cnenttx: nil, cnentty: nil, cnenttz: nil, lengthcnentt: sideLangthcnentt * 0.4, degreesRightcnentt: 120)))
        contextcnentt.addArc(center: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0, y: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0), radius: sideLangthcnentt * 0.4, startAngle: 240 * CGFloat.pi / 180 , endAngle: 300 * CGFloat.pi / 180, clockwise: true)
        
        contextcnentt.move(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0, y: contextSizecnentt * 0.1))
        contextcnentt.addLine(to: CGPoint(x: contextSizecnentt * 0.1 + sideLangthcnentt / 2.0, y: contextSizecnentt * 0.1 + sideLangthcnentt * 0.4))
        
        contextcnentt.setLineWidth(strokeWidthcnentt)
        if let colorcnentt = arrowColorcnentt {
            contextcnentt.setStrokeColor(colorcnentt.cgColor)
        } else {
            contextcnentt.setStrokeColor(UIColor.clear.cgColor)
        }
        contextcnentt.strokePath()
    }
    
    let imgcnentt = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return imgcnentt
}
