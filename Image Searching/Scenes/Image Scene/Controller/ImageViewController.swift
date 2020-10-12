//
//  ImageViewController.swift
//  Image Searching
//
//  Created by Agil Madinali on 10/7/20.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.keyboardDismissMode = .onDrag
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var timer: Timer?
    let operationQueue = OperationQueue()
    
    var providersArray: [Provider] = [
            Provider(name: "Splash", url: Splash.url, parameters: Splash.parameters, headers: nil),
            Provider(name: "Pexels", url: Pexels.url, parameters: Pexels.parameters, headers: Pexels.headers),
            Provider(name: "Pixabay", url: Pixabay.url, parameters: Pixabay.parameters, headers: nil)]
    var sectionDataSourceStored: [Sections] = []
    var sectionDataSource: [Sections] {
        return sectionDataSourceStored
    }
    var selectedFilter: ImageFilterType = .original
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        self.title = "Images"
        self.setupKeyboardHandlers()
        
        self.collectionView.isHidden = true
        self.warningLabel.isHidden = false
        self.activityIndicator.isHidden = true
        
        self.searchBar.delegate = self
        self.collectionView.reloadData()
    }
    
    func setupKeyboardHandlers() {
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func getImages(about text: String) {
        self.operationQueue.maxConcurrentOperationCount = 2
        
        let notifyOperation = BlockOperation {
            OperationQueue.main.addOperation {
                self.activityIndicator.stopAnimating()
                
                if self.sectionDataSource.isEmpty {
                    self.warningLabel.isHidden = false
                    self.collectionView.isHidden = true
                } else {
                    self.warningLabel.isHidden = true
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                }
            }
        }
        
        self.providersArray.forEach { provider in
            let fetchOperation = FetchOperation(provider: provider, text: text)
            
            fetchOperation.completionBlock = {
                guard let section = fetchOperation.section else { return }
                DispatchQueue.global().sync(flags: .barrier) {
                    self.sectionDataSourceStored.append(section)
                }
            }
            notifyOperation.addDependency(fetchOperation)
            self.operationQueue.addOperation(fetchOperation)
        }
        self.operationQueue.addOperation(notifyOperation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let filterVC = segue.destination as? FilterViewController else { return }
        
        var providers = [Provider]()
        self.sectionDataSource.forEach { section in
            providers.append(section.provider)
        }
        filterVC.providers = providers
        filterVC.selectedFilterType = self.selectedFilter
        filterVC.delegate = self
        filterVC.filterDelegate = self
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sectionDataSource.filter { $0.provider.isOn }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let displaySections = self.sectionDataSource.filter { $0.provider.isOn }
        return displaySections[section].dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath)
                as? ImageCollectionViewCell else { fatalError("Cell cannot be dequeued!")}
        
        let displaySections = self.sectionDataSource.filter { $0.provider.isOn }
        let url = displaySections[indexPath.section].dataSource[indexPath.row].imageUrl ?? ""
        
        cell.configureCell(imageUrl: url, filter: self.selectedFilter)
        return cell
    }
}

extension ImageViewController: ProviderDelegate {
    
    func updateProviders(provider: Provider, isOn: Bool) {
        for (index, section) in self.sectionDataSource.enumerated() where section.provider == provider {
            self.sectionDataSourceStored[index].provider.isOn = isOn
        }
        self.collectionView.reloadData()
    }
}

extension ImageViewController: FilterDelegate {
    
    func updateFilters(with filter: ImageFilterType) {
        self.selectedFilter = filter
        self.collectionView.reloadData()
    }
}

extension ImageViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let timer = self.timer {
            timer.invalidate()
            self.operationQueue.cancelAllOperations()
            self.activityIndicator.stopAnimating()
        }
        
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count < 5 { return }

        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: false) { _ in
            self.warningLabel.isHidden = true
            self.activityIndicator.startAnimating()
            self.sectionDataSourceStored.removeAll()
            self.getImages(about: text)
        }
    }
}
