//
//  SearchViewController.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import UIKit
import RxSwift
import SafariServices

class SearchViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModel
    
    private lazy var leftView : UIStackView = {
        let stackView = UIStackView()
        let imageView = UIImageView(image: UIImage(named: "SearchIcon")?.with(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)))
        
        stackView.addArrangedSubview(imageView)
        return stackView
    }()
    private lazy var textField: UITextField  = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(hexCode: Color.TextFieldBackColor)
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 4
        textField.leftViewMode = .always
        textField.returnKeyType = .search
        textField.leftView = leftView
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(UIColor(hexCode: Color.TextGrayColor), for: .normal)
        return button
    }()
    
    private lazy var searchStackView: SearchView = {
        let stackView = SearchView(arrangedSubviews: [textField, cancelButton])
        stackView.spacing = 6
        return stackView
    }()
    
    private lazy var historyTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = Cell.SearchCellHeight
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.tableHeaderView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset.left = 0
        return tableView
    }()
    
    private lazy var webtoonTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)
        tableView.register(WebtoonCell.self, forCellReuseIdentifier: WebtoonCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var emptyHistoryView: UIStackView = {
        let stackView = TextImageView(image: TextViewData.emptyHistory.info.image, text: TextViewData.emptyHistory.info.text)
        return stackView
    }()
    
    private lazy var emptyResultView: UIStackView = {
        let stackView = TextImageView(image: TextViewData.emptyWebtoon.info.image, text: TextViewData.emptyWebtoon.info.text)
        return stackView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        addViews()
        setConstraints()
        setupBindings()
    }

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.endEditing(true)
    }
    
    private func configureUI(){
        view.backgroundColor = UIColor(hexCode: Color.BackColor)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.titleView = searchStackView
    }
    
    private func addViews(){
        view.addSubview(historyTableView)
        view.addSubview(webtoonTableView)
        view.addSubview(emptyHistoryView)
        view.addSubview(emptyResultView)
    }
    
    private func setConstraints(){
        historyTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        webtoonTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyResultView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        emptyHistoryView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupBindings(){
        
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        // 검색기록 데이터 가져오기
        textField.rx.text
            .filter({ text in
                return text == nil || text == ""
            })
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.fetchHistory.onNext(())
            })
            .disposed(by: disposeBag)
       
        // 검색어 클릭 이벤트, search 버튼 클릭 -> 검색어 전달
        let selectKeyword = historyTableView.rx.modelSelected(SearchTerm.self).map({ data in data.keyword }).do(onNext: {[weak self] data in self?.textField.text = data})
        let searchTapped = textField.rx.controlEvent(.editingDidEndOnExit).map({ [weak self] in
            guard let text = self?.textField.text else { return "" }
            return text })
        
        Observable.merge([selectKeyword, searchTapped])
            .subscribe({ [weak self] data in
                guard let searchTerm = data.element else { return }
                self?.viewModel.searchKeyword.onNext(searchTerm)
                self?.textField.endEditing(true)
                LoadingIndicator.showLoading()
            })
            .disposed(by: disposeBag)

        
        // ------------------------------
        //     NAVIGATION
        // ------------------------------
        
        // 취소 버튼 선택 이벤트 -> 이전 화면으로 돌아가기
        cancelButton.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 웹툰 클릭 시 웹페이지 표시
        webtoonTableView.rx.modelSelected(Webtoon.self)
            .subscribe({ [weak self] webtoon in
                guard let urlString = webtoon.element?.url, let url = URL(string: urlString) else { return }
                let safariView: SFSafariViewController = SFSafariViewController(url: url)
                self?.present(safariView, animated: true)
            })
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
        // 타입 변경에 따른 컨텐츠 Hidden 처리
        viewModel.viewType
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                
                self.historyTableView.isHidden = true
                self.webtoonTableView.isHidden = true
                self.emptyResultView.isHidden = true
                self.emptyHistoryView.isHidden = true
                
                switch type {
                case .NoExistSearchHistory:
                    emptyHistoryView.isHidden = false
                    break
                case .ExistSearchHistory :
                    historyTableView.isHidden = false
                    break
                case .CompleteSearch :
                    webtoonTableView.isHidden = false
                    break
                case .CompleteSearchNoExist :
                    emptyResultView.isHidden = false
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // 선택된 서비스 이름 표시
        viewModel.boardTitle
            .map { board in
                "\(board.rawValue)에서 검색"
            }
            .bind(to: textField.rx.placeholder)
            .disposed(by: disposeBag)
        
        
        // 검색 기록 표시
        viewModel.historys
            .map({ [weak self] data in
                self?.viewModel.changeType.onNext(data.count > 0 ? .ExistSearchHistory : .NoExistSearchHistory)
                self?.historyTableView.scrollToRow(at: NSIndexPath(row: NSNotFound, section: 0) as IndexPath, at: .top, animated: false)
                return data
            })
            .bind(to: historyTableView.rx.items(cellIdentifier: HistoryCell.identifier,
                                                cellType: HistoryCell.self)) { _, item, cell in
                cell.onData.onNext(item)
                cell.removePressed = {
                    self.viewModel.removeHistory.onNext(item)
                    self.viewModel.fetchHistory.onNext(())
                }
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        
        // 검색된 웹툰 표시, 로딩창 내리기, scroll to top
        viewModel.allPosts
            .do(onNext: { [weak self] post in
                self?.viewModel.changeType.onNext(post.count > 0 ? .CompleteSearch : .CompleteSearchNoExist)
                LoadingIndicator.hideLoading()
                self?.webtoonTableView.scrollToRow(at: NSIndexPath(row: NSNotFound, section: 0) as IndexPath, at: .top, animated: false)
            })
            .bind(to: webtoonTableView.rx.items(cellIdentifier: WebtoonCell.identifier,
                                             cellType: WebtoonCell.self)) { index, item, cell in
                cell.onData.onNext(item)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}
