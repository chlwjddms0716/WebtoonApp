//
//  HistoryCell.swift
//  WebtoonApp
//
//  Created by 최정은 on 11/2/23.
//

import UIKit
import RxSwift

class HistoryCell: UITableViewCell {

    static let identifier = "HistoryCell"
    
    let disposeBag = DisposeBag()
    
    var onData: AnyObserver<SearchTerm>
    var removePressed: () -> Void = {   }
    
    private let recentImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Recent"))
        return imageView
    }()
                                                   
    private let keywordLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "cellClose"), for: .normal)
        button.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [recentImageView, keywordLabel, removeButton])
        stackView.spacing = 10
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let data = PublishSubject<SearchTerm>()
       
        onData = data.asObserver()
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchHistory in
                guard let self = self else { return }
                keywordLabel.text = searchHistory.keyword
            })
            .disposed(by: disposeBag)
        
        configureUI()
        addViews()
        setConstraints()
    }
    
    @objc func removeButtonTapped(){
        removePressed()
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(){
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    private func addViews(){
        self.contentView.addSubview(stackView)
    }
    
    private func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        stackView.arrangedSubviews.forEach { item in
            item.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        }
        
        keywordLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}
