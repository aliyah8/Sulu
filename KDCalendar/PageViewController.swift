/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class PageViewController: UIPageViewController {
    
    let petCards = PetCardStore.defaultPets()
    let petCards2 = PetCardStore.defaultPets2()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)
    }
    
    var selectedIndex = 0
    
    func changeSegment(index: Int) {
        selectedIndex = index
        dataSource = nil
        dataSource = self
        setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)
        //        switch(index)
        //        {
        //        case 1: petCard?.descriptionKz =
        //
        //        case 0:
        //            code
        //        }
    }
}

// MARK: Page view controller data source

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? CardViewController, let pageIndex = viewController.pageIndex where pageIndex > 0 {
            return viewControllerAtIndex(pageIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let viewController = viewController as? CardViewController, let pageIndex = viewController.pageIndex where pageIndex < (selectedIndex == 0 ? petCards.count : petCards2.count) - 1 {
            return viewControllerAtIndex(pageIndex + 1)
        }
        
        return nil
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return selectedIndex == 0 ? petCards.count : petCards2.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// MARK: View controller provider

extension PageViewController: ViewControllerProvider {
    
    var initialViewController: UIViewController {
        return viewControllerAtIndex(0)!
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        
        if let cardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CardViewController") as? CardViewController {
            
            cardViewController.pageController = self
            cardViewController.selectedIndex = selectedIndex
            cardViewController.pageIndex = index
            cardViewController.petCard = selectedIndex == 0 ? petCards[index] : petCards2[index]
            
            return cardViewController
        }
        
        return nil
    }
}