//
//  SNESSelectGameStateViewController.swift
//  SuperNES
//
//  Created by Joride on 04-07-15.
//  Copyright (c) 2015 SuperNES. All rights reserved.
//

import UIKit

class SNESSelectGameStateViewController : UIViewController, SNESSelectGameStateViewControllerDelegate
{
    // needs to be set so that the app does not run into a dead end
    var completion : ((String) -> Void)?

    // the ROM for which to show the saved states
    var ROM : SNESROMFileManaging?

    let dataSource = SNESSelectGameStateDataSource()

    @IBOutlet weak private var collectionView: UICollectionView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.dataSource.ROM = self.ROM
        self.dataSource.delegate = self
        dataSource.collectionView = self.collectionView
        self.collectionView.dataSource = dataSource
        self.collectionView.delegate = dataSource
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width,
            self.view.bounds.size.width / 1.3659 + 50)
        flowLayout.minimumInteritemSpacing = 10.0

        self.collectionView.collectionViewLayout = flowLayout
    }
    func selectGameStateDataSourceDelegate(dataSource: SNESSelectGameStateDataSource, didSelectSaveStatePath path: String)
    {
        if let completion = self.completion
        {
            completion(path)
        }
        else
        {
            print("WARNING: no completionHandler. THe app has reached a dead end with this viewCOntroller")
        }
    }
}



@objc protocol SNESSelectGameStateViewControllerDelegate
{
    func selectGameStateDataSourceDelegate(dataSource: SNESSelectGameStateDataSource, didSelectSaveStatePath path : String);
}
class SNESSelectGameStateDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate
{
    weak var delegate : SNESSelectGameStateViewControllerDelegate?

    var dateFormatter : NSDateFormatter

    let  cellID = "cellID";
    weak var _collectionView: UICollectionView?
    var collectionView: UICollectionView? {
        get {
            return _collectionView
        }
        set (newCollectionView)
        {
            _collectionView = newCollectionView
            self.registerCellsWithCollectionView()
        }
    }

    var _ROM : SNESROMFileManaging?
    var ROM : SNESROMFileManaging?{
        get {
            return _ROM
        }
        set (newROM)
        {
            _ROM = newROM
            self.collectionView?.reloadData()
        }
    }

    override init()
    {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.timeStyle = .ShortStyle
        self.dateFormatter.dateStyle = .MediumStyle
        self.dateFormatter.locale = NSLocale.currentLocale()
    }


    func registerCellsWithCollectionView()
    {
    let nibName = "SNESGameCollectionViewCell"
        let nib = UINib(nibName: nibName, bundle: NSBundle.mainBundle())
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier:  cellID)
    }

    /// CollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let numberOfItems : Int
        if let count = self.ROM?.saveStates.count
        {
            numberOfItems = count
        }
        else
        {
            numberOfItems = 0
        }
        return numberOfItems
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as! SNESGameCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    func configureCell(cell : SNESGameCollectionViewCell, atIndexPath indexPath : NSIndexPath)
    {
        let state = self.ROM?.saveStates[indexPath.item]

        let dateString = self.dateFormatter.stringFromDate(state!.saveDate)

        if (dateString.characters.count > 0)
        {
            cell.titleLabel!.text = dateString
        }
        else
        {
            cell.titleLabel!.text = self.ROM?.ROMName
        }

        let screenCaptureFilePath = state?.screenCaptureFilePath
        if let image = UIImage(contentsOfFile: screenCaptureFilePath!)
        {
            cell.imageView!.image = image;
        }
        else
        {
            if let imagePath = self.ROM?.imagePath
            {
                let image = UIImage(contentsOfFile: imagePath)
                cell.imageView!.image = image;
            }
            else
            {
                cell.imageView!.image = nil
            }
        }
    }

    /// UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let index = indexPath.item
        let saveState = self.ROM?.saveStates[index]
        let path = saveState!.saveStateFilePath
        self.delegate?.selectGameStateDataSourceDelegate(self, didSelectSaveStatePath: path)
    }
}









