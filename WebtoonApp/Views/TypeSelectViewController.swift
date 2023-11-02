//
//  TypeSelectViewController.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import UIKit
import RxSwift

class TypeSelectViewController: UIViewController {

    private let viewModel: TypeSelectViewModel
    private let disposeBag = DisposeBag()
    
    private lazy var closeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "close"), for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
    let label = UILabel()
        label.text = "서비스"
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.rowHeight = Cell.WebtoonTypeCellHeight
        tableView.separatorStyle = .none
        tableView.register(WebtoonTypeCell.self, forCellReuseIdentifier: WebtoonTypeCell.identifier)
        return tableView
    }()
    
    private let lineView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(hexCode: Color.GrayColor)
        return view
    }()
    
    private lazy var topStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [closeButton, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .leading
       stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [topStackView, lineView, tableView])
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    init(viewModel: TypeSelectViewModel = TypeSelectViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        viewModel = TypeSelectViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureUI()
        addViews()
        setConstraints()
        setupBindings()
    }
    
    private func configureUI(){
        view.backgroundColor = UIColor(hexCode: Color.BackColor)
    }

    private func addViews(){
        view.addSubview(mainStackView)
    }
    
    private func setConstraints(){
        
        closeButton.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
        }

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupBindings(){
        
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        // 닫기 버튼 클릭 이벤트 -> 페이지 닫기
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // 서비스 선택 이벤트 -> 선택한 서비스 타입 전달
        tableView.rx.modelSelected(WebtoonType.self)
            .subscribe(onNext: { [weak self] board in
                self?.viewModel.selectBoard.onNext(board)
            })
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        // 서비스 종류 표시
        viewModel.boardItems
            .bind(to: tableView.rx.items(cellIdentifier: WebtoonTypeCell.identifier,
                                         cellType: WebtoonTypeCell.self)) {
                _, item, cell in
                
                cell.selectionStyle = .none
                cell.onData.onNext(item)
            }
            .disposed(by: disposeBag)
    }

}
