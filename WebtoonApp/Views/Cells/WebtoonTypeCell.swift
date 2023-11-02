//
//  WebtoonTypeCell.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import UIKit
import RxSwift

class WebtoonTypeCell: UITableViewCell {

    static let identifier = "WebtoonTypeCell"
    
    private let cellDisposeBag = DisposeBag()
    var onData: AnyObserver<WebtoonType>
    
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let data = PublishSubject<WebtoonType>()
       
        onData = data.asObserver()
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        data.observe(on: MainScheduler.instance)
            .map({type in return type.rawValue})
            .bind(to: nameLabel.rx.text)
            .disposed(by: cellDisposeBag)
        
        addViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addViews(){
        self.contentView.addSubview(nameLabel)
    }
    
    private func setConstraints(){
        nameLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
    }

}
