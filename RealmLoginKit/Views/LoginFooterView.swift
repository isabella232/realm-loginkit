////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import UIKit

enum LoginFooterViewStyle {
    case light
    case dark
}

class LoginFooterView: UIView {
    
    public var style: LoginHeaderViewStyle = .light {
        didSet { applyTheme() }
    }
    
    private let viewHeight = 145 // Overall height of the view
    private let loginButtonHeight = 50
    private let loginButtonWidthScale = 0.8
    
    private let topMargin = 15
    private let middleMargin = 35
    
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    public var isSubmitButtonEnabled: Bool = false {
        didSet {
            updateSubmitButton()
        }
    }
    
    var loginButtonTapped: (() -> Void)?
    var registerButtonTapped: (() -> Void)?
    
    private var _registering: Bool = false
    var registering: Bool {
        set {
            setRegistering(newValue, animated: false)
        }
        
        get { return _registering }
    }
    
    var isSubmitting: Bool = false {
        didSet {
            updateLoadingIndicator()
        }
    }
    
    override init(frame: CGRect) {
        var newRect = frame
        newRect.size.height = CGFloat(viewHeight)
        super.init(frame: newRect)
        setUpViews()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Handling
    
    private func setUpViews() {
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        loginButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        loginButton.isEnabled = false
        addSubview(loginButton)
        
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        registerButton.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        addSubview(registerButton)
        
        loadingIndicator.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        
        updateButtonTitles()
        updateSubmitButton()
        
        applyTheme()
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = loginButton.frame
        rect.origin.y = CGFloat(topMargin)
        rect.size.width = bounds.size.width * CGFloat(loginButtonWidthScale)
        rect.size.height = CGFloat(loginButtonHeight)
        rect.origin.x = (bounds.size.width - rect.size.width) * 0.5
        loginButton.frame = rect
        
        registerButton.sizeToFit()
        rect = registerButton.frame
        rect.size.height = 44
        rect.size.width *= 1.2
        rect.origin.y = loginButton.frame.maxY + CGFloat(middleMargin)
        rect.origin.x = (bounds.size.width - rect.size.width) * 0.5
        registerButton.frame = rect
    }

    private func applyTheme() {
        let isDarkTheme = style == .dark
        
        if isDarkTheme {
            loginButton.backgroundColor = UIColor(red: 0.941, green: 0.278, blue: 0.529, alpha: 1.0)
            
            let registerColor = UIColor(red: 0.533, green: 0.521, blue: 0.898, alpha: 1.0)
            registerButton.layer.borderColor = registerColor.cgColor
            registerButton.setTitleColor(registerColor, for: .normal)
        }
        else {
            loginButton.backgroundColor = UIColor(red: 0.941, green: 0.278, blue: 0.529, alpha: 1.0)
            
            let registerColor = UIColor(red: 0.345, green: 0.337, blue: 0.615, alpha: 1.0)
            registerButton.layer.borderColor = registerColor.cgColor
            registerButton.setTitleColor(registerColor, for: .normal)
        }
        
        updateSubmitButton()
    }
    
    func buttonTapped(sender: AnyObject?) {
        guard let sender = sender else {
            return
        }
        
        if sender as! NSObject == loginButton {
            loginButtonTapped?()
        }
        else {
            registerButtonTapped?()
        }
    }

    private func updateButtonTitles() {
        let loginText: String , registerText: String
        
        if _registering {
            loginText = "Sign Up"
            registerText = "Log Into Your Account"
        }
        else {
            loginText = "Log In"
            registerText = "Register a New Account"
        }
        
        loginButton.setTitle(loginText, for: .normal)
        registerButton.setTitle(registerText, for: .normal)
    }
    
    private func updateSubmitButton() {
        
        loginButton.isEnabled = isSubmitButtonEnabled
        
        let isDarkTheme = style == .dark
        let alpha = isDarkTheme ? 0.4 : 0.7
        loginButton.alpha = isSubmitButtonEnabled ? 1.0 : CGFloat(alpha)
    }
    
    private func updateLoadingIndicator() {
        if isSubmitting {
            loginButton.setTitle(nil, for: .normal)
            registerButton.isEnabled = false
            
            loadingIndicator.frame.origin.x = loginButton.bounds.midX - loadingIndicator.bounds.midX
            loadingIndicator.frame.origin.y = loginButton.bounds.midY - loadingIndicator.bounds.midY
            loginButton.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
        }
        else {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
            
            registerButton.isEnabled = true
            updateButtonTitles()
        }
    }
    
    func setRegistering(_ registering: Bool, animated: Bool) {
        guard registering != _registering else {
            return
        }
        
        _registering = registering
        
        if animated == false {
            updateButtonTitles()
            return
        }
        
        UIView.transition(with: loginButton, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            self.updateButtonTitles()
        }, completion: nil)
    }
}
