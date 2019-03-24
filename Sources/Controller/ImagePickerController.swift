// The MIT License (MIT)
//
// Copyright (c) 2019 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

// MARK: ImagePickerController
public class ImagePickerController: UINavigationController {
    // MARK: Public properties
    public weak var imagePickerDelegate: ImagePickerControllerDelegate?
    public var settings: Settings = Settings()
    public var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
    public var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    public var albumButton: UIButton = UIButton(type: .system)
    public var assetStore: AssetStore = AssetStore(assets: [])

    // MARK: Internal properties
    var onSelection: ((_ asset: PHAsset) -> Void)?
    var onDeselection: ((_ asset: PHAsset) -> Void)?
    var onCancel: ((_ assets: [PHAsset]) -> Void)?
    var onFinish: ((_ assets: [PHAsset]) -> Void)?
    var onSelectionLimitReached: ((_ selectionLimit: Int) -> Void)?
    let assetsViewController = AssetsViewController()
    let albumsViewController = AlbumsViewController()
    let dropdownTransitionDelegate = DropdownTransitionDelegate()
    let zoomTransitionDelegate = ZoomTransitionDelegate()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sync settings
        albumsViewController.settings = settings
        assetsViewController.settings = settings
        
        // Setup view controllers
        albumsViewController.delegate = self
        assetsViewController.delegate = self
        
        viewControllers = [assetsViewController]
        view.backgroundColor = settings.theme.backgroundColor
        delegate = zoomTransitionDelegate
        
        // Setup buttons
        let firstViewController = viewControllers[0]
        albumButton.setTitleColor(albumButton.tintColor, for: .normal)
        albumButton.setTitle("Some title for inital selection", for: .normal) // TODO: <---
        albumButton.setImage(UIImage(named: "arrow_down", in: Bundle(for: ImagePickerController.self), compatibleWith: nil), for: .normal)
        albumButton.imageToRight()
        albumButton.addTarget(self, action: #selector(ImagePickerController.albumsButtonPressed(_:)), for: .touchUpInside)
        firstViewController.navigationItem.titleView = albumButton
        doneButton.target = self
        doneButton.action = #selector(ImagePickerController.doneButtonPressed(_:))
        firstViewController.navigationItem.rightBarButtonItem = doneButton
        cancelButton.target = self
        cancelButton.action = #selector(ImagePickerController.cancelButtonPressed(_:))
        firstViewController.navigationItem.leftBarButtonItem = cancelButton
        
        toggleDoneButton()
    }

    func toggleDoneButton() {
        doneButton.isEnabled = assetStore.count >= settings.selection.min
    }
}