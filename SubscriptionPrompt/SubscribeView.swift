//
//  SubscribeView.swift
//  KanjiNinja
//
//  Created by Zhanserik on 4/28/16.
//  Copyright © 2016 Tom. All rights reserved.
//

import UIKit
import SnapKit

private let collectionViewCellIdentifier = "collectionViewCellIdentifier"
private let tableViewCellIdentifier = "identifier"

protocol SubscribeViewDelegate {
    func dismissButtonTouched()
}

extension SubscribeViewDelegate where Self: UIViewController {
    func dismissButtonTouched() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

final class SubscribeView: UIView {
    var delegate: SubscribeViewDelegate?
    
    var title = "Get [App Name] Plus"
    var subscribeOptionsTexts = ["12 MONTHS FOR $4.58/mo", "6 MONTHS FOR $5.83/mo", "1 MONTH FOR $9.99/mo"] {
        didSet { reloadTableView() }
    }
    var cancelOptionText = "CANCEL" {
        didSet { reloadTableView() }
    }
    var images = [UIImage]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        }
    }
    var commentTexts = [String]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        }
    }
    var commentSubtitleTexts = [String]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFontOfSize(24)
        label.text = "Get Kanji Ninja Plus"
        label.textAlignment = .Center
        return label
    }()
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .Horizontal
        return layout
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = .whiteColor()
        collectionView.registerClass(SubscribeCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellIdentifier)
        return collectionView
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.scrollEnabled = false
        tableView.separatorStyle = .None
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: tableViewCellIdentifier)
        return tableView
    }()
    
    private var constraintsSetUp = false
    
    // MARK: - Init
    
    convenience init(title: String, images: [UIImage], commentTexts: [String], commentSubtitleTexts: [String],
                     subscribeOptionsTexts: [String], cancelOptionText: String) {
        self.init(frame: .zero)
        self.title = title
        self.images = images
        self.commentTexts = commentTexts
        self.commentSubtitleTexts = commentSubtitleTexts
        self.subscribeOptionsTexts = subscribeOptionsTexts
        self.cancelOptionText = cancelOptionText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Public
    
    func animateDraggingToTheRight(duration: NSTimeInterval = 2) {
        UIView.animateWithDuration(duration / 2, animations: {
            self.collectionView.contentOffset = CGPoint(x: 120, y: 0)
            self.layoutIfNeeded()
        }) {
            if !$0 { return }
            UIView.animateWithDuration(duration / 2) {
                self.collectionView.contentOffset = CGPoint(x: 0, y: 0)
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Private
    
    private func setupViews() {
        backgroundColor = .whiteColor()
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        [titleLabel, collectionView, tableView].forEach { self.addSubview($0) }
        collectionView.reloadData()
        tableView.reloadData()
        setNeedsUpdateConstraints()
    }
    
    private func reloadTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.tableView.snp_updateConstraints {
                $0.height.equalTo(self.tableView.contentSize.height)
            }
        }
    }
    
    // MARK: - UIView
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if constraintsSetUp { return }
        constraintsSetUp = true
        
        titleLabel.snp_makeConstraints {
            $0.left.equalTo(snp_left)
            $0.right.equalTo(snp_right)
            $0.top.equalTo(snp_top).offset(16)
        }
        collectionView.snp_makeConstraints {
            $0.left.equalTo(snp_left)
            $0.right.equalTo(snp_right)
            $0.top.equalTo(titleLabel.snp_bottom)
        }
        tableView.snp_makeConstraints {
            $0.left.equalTo(snp_left)
            $0.right.equalTo(snp_right)
            $0.top.equalTo(collectionView.snp_bottom)
            $0.bottom.equalTo(snp_bottom)
            $0.height.equalTo(tableView.contentSize.height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.itemSize = CGSize(width: collectionView.bounds.width,
                                 height: collectionView.bounds.height)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SubscribeView: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscribeOptionsTexts.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier)!
        cell.contentView.backgroundColor = UIColor.orangeColor()
            .colorWithAlphaComponent(1 / (CGFloat(indexPath.row) + 1) + 0.2)
        cell.textLabel?.font = .systemFontOfSize(17)
        cell.textLabel?.textColor = .whiteColor()
        cell.textLabel?.textAlignment = .Center
        
        cell.textLabel?.text = indexPath.row < subscribeOptionsTexts.count ?
            subscribeOptionsTexts[indexPath.row] : cancelOptionText
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let delegate = delegate where
            indexPath.row == subscribeOptionsTexts.count else { return }
        delegate.dismissButtonTouched()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SubscribeView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            collectionViewCellIdentifier, forIndexPath: indexPath) as! SubscribeCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        cell.commentLabel.text = commentTexts[indexPath.row]
        cell.commentSubtitleLabel.text = commentSubtitleTexts[indexPath.row]
        return cell
    }
}