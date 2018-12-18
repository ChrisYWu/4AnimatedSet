//
//  ConcentrationThemeViewController.swift
//  4AnimatedSet
//
//  Created by Chris Wu on 12/12/18.
//  Copyright © 2018 Wu Personal Team. All rights reserved.
//

import UIKit

class ThemeChooserVC: UIViewController, UISplitViewControllerDelegate {
    
    private var themeIndexMapping = [String:Int]()
    private var lastSeguedCVC : ConcentrationViewController?
    
    @IBAction func changeTheme(_ sender: Any) {
        if let cvc = splitViewDetailConcentrationViewController {
            //This branch is supposed to be for split view with iPad
            if let themeName = (sender as? UIButton)?.currentTitle, let index = themeIndexMapping[themeName] {
                cvc.theme = index
            }
        }
        else if lastSeguedCVC != nil {
            //This branch handles the iPhone trait, where there is no Master/Detailed Controller
            if let theme = (sender as? UIButton)?.currentTitle, let index = themeIndexMapping[theme] {
                lastSeguedCVC?.theme = index
                navigationController?.pushViewController(lastSeguedCVC!, animated: true)
            }
        }
        else {
            performSegue(withIdentifier: "Choose Theme", sender: sender)
        }
    }
    
    private var splitViewDetailConcentrationViewController: ConcentrationViewController? {
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        splitViewController?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeIndexMapping.removeAll()
        themeIndexMapping["Animals"] = 0
        themeIndexMapping["Sports"] = 3
        themeIndexMapping["Faces"] = 1
        themeIndexMapping["Vegetables"] = 2
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        //print("collapseSecondary called")
        // The following logic seems to be useless, this just get called once anyway
        if let cvc = secondaryViewController as? ConcentrationViewController {
            return cvc.themeNotSet
        }
        else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let name = segue.identifier, name == "Choose Theme" {
            if let game = segue.destination as? ConcentrationViewController,
                let theme = (sender as? UIButton)?.currentTitle,
                let index = themeIndexMapping[theme] {
                game.themeNotSet = false
                game.theme = index
                lastSeguedCVC = game
            }
        }
    }
    

}
