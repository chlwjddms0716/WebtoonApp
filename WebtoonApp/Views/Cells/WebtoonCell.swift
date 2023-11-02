//
//  WebtoonCell.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/1/23.
//

import RxSwift
import UIKit

class WebtoonCell: UITableViewCell {

    static let identifier = "WebtoonCell"
    
    private let cellDisposeBag = DisposeBag()
    var onData: AnyObserver<Webtoon>

    private let thumbnailImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(hexCode: Color.GrayColor).cgColor
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let authorLabel: VerticalAlignLabel = {
       let label = VerticalAlignLabel()
        label.verticalAlignment = .top
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hexCode: Color.TextGrayColor)
        label.textAlignment = .left
        return label
    }()
    
    private let fanCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
   private let dayStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.spacing = 3
        return stackView
    }()
    
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel, dayStackView])
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    
    private let webImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "caret-arrow")?.withTintColor(UIColor(hexCode: Color.arrowColor), renderingMode: .alwaysOriginal))
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: Cell.WebtoonCellLineHeight, left: 20, bottom: Cell.WebtoonCellLineHeight, right: 20))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let data = PublishSubject<Webtoon>()
        onData = data.asObserver()
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        addViews()
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] webtoon in
                guard let self = self else { return }
                titleLabel.text = webtoon.title
                authorLabel.text = webtoon.author
                if let count = webtoon.fanCount {
                    fanCountLabel.text = "관심 \(count)만+"
                }
                
                removeInStackView()
                
                webtoon.updatedayList.forEach { updateDay in
                    let keyword = KeywordLabel(keyword: updateDay.rawValue)
                    keyword.sizeToFit()
                    self.dayStackView.addArrangedSubview(keyword)
                }
                dayStackView.addArrangedSubview(fanCountLabel)
                
                thumbnailImageView.load(url: webtoon.img)
                
                setConstraints()
            })
            .disposed(by: cellDisposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor(hexCode: Color.GrayColor).cgColor
    }
   
    private func addViews(){
        self.contentView.addSubview(thumbnailImageView)
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(webImageView)
    }
    
    private func setConstraints(){
        thumbnailImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(Cell.WebtoonCellImageSpace)
            make.width.equalTo(Cell.WebtoonImageWidth)
            make.height.equalTo(Cell.WebtoonImageHeight)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            make.top.bottom.equalTo(thumbnailImageView)
            make.trailing.equalTo(webImageView).inset(20)
        }
        
        webImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalTo(thumbnailImageView)
        }
        
        mainStackView.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                view.setContentHuggingPriority(.defaultHigh, for: .vertical)
            }
        }
        
        authorLabel.snp.makeConstraints { make in
            authorLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        }

     
        dayStackView.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
        }
        
        fanCountLabel.snp.makeConstraints { make in
            fanCountLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }
    
    private func removeInStackView() {
        for item in dayStackView.arrangedSubviews {
            dayStackView.removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }
}
