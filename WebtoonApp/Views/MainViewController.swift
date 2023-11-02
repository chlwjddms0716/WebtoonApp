//
//  MainViewController.swift
//  WebtoonApp
//
//  Created by 최정은 on 10/31/23.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import SafariServices

class MainViewController: UIViewController {

    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
     
     private lazy var titleLabel: UILabel = {
         guard let navFrame = self.navigationController?.navigationBar.frame else { return UILabel() }
         let parentView = UIView(frame: CGRect(x: 0, y: 0, width: navFrame.width*3, height: navFrame.height))
         
         let label = UILabel(frame: .init(x: parentView.frame.minX, y: parentView.frame.minY, width: parentView.frame.width, height: parentView.frame.height))
         label.numberOfLines = 2
         label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
         label.textAlignment = .left
         parentView.addSubview(label)
         navigationItem.titleView = parentView
         return label
     }()
     
    private lazy var selectButton: UIBarButtonItem = {
         let button = UIBarButtonItem(image: UIImage(named: "hamburger menu")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
             return button
         }()
     
     private lazy var searchButton: UIBarButtonItem = {
         let button = UIBarButtonItem(image: UIImage(named: "SearchIcon")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
             return button
         }()
   
    private lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10,left: 0,bottom: 0,right: 0)
        tableView.separatorStyle = .none
        tableView.register(WebtoonCell.self, forCellReuseIdentifier: WebtoonCell.identifier)
        tableView.tableFooterView = spinnerFooter
        return tableView
    }()
    
    private lazy var spinnerFooter: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }()
    
     override func viewDidLoad() {
         super.viewDidLoad()
         
         configureUI()
         setupNavigationBar()
         addViews()
         setConstraints()
         setupBindings()
         
         LoadingIndicator.showLoading()
     }
     
     override func viewWillAppear(_ animated: Bool) {
         
     }

     init(viewModel: MainViewModel) {
         self.viewModel = viewModel
         super.init(nibName: nil, bundle: nil)
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     
     private func configureUI(){
         view.backgroundColor = UIColor(hexCode: Color.BackColor)
     }
     
     private func setupNavigationBar(){
         navigationItem.leftBarButtonItem = selectButton
         navigationItem.rightBarButtonItem = searchButton
         
         navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .medium)]
         
         navigationController?.additionalSafeAreaInsets.top = 10
     }
     
     private func addViews(){
         view.addSubview(tableView)
     }
     
     private func setConstraints(){
         tableView.snp.makeConstraints { make in
             make.top.equalTo(view.safeAreaLayoutGuide)
             make.leading.trailing.bottom.equalToSuperview()
         }
     }
     
     
    private func setupBindings() {
         
        // ------------------------------
        //     INPUT
        // ------------------------------
        
        // select 버튼 클릭 이벤트 -> 서비스 선택 페이지 띄우기
        selectButton.rx.tap
            .bind(to: viewModel.tapServicePage)
            .disposed(by: disposeBag)
        
        
        // 페이징처리 - 스크롤
        tableView.rx.didScroll
            .filter({
                let offSetY = self.tableView.contentOffset.y
                let contentHeight = self.tableView.contentSize.height

                return  offSetY > (contentHeight - self.tableView.frame.size.height - 100)
            })
            .subscribe { [weak self] _ in
                self?.viewModel.pagingPost.onNext(())
        }
        .disposed(by: disposeBag)
        
        
        // ------------------------------
        //     NAVIGATION
        // ------------------------------
        
         // 서비스 종류 전달 및 서비스 선택 화면 이동
        viewModel.showBoardPage
            .subscribe( onNext: { [weak self] _ in
                let vm = TypeSelectViewModel()
                let vc = TypeSelectViewController(viewModel: vm)
                vm.closePage
                    .subscribe(onNext: { [weak self] board in
                        LoadingIndicator.showLoading()
                        self?.viewModel.selectWebtoonType.onNext(board)
                        
                        vc.dismiss(animated: true)
                    })
                    .disposed(by: vm.disposeBag)
                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // 검색 버튼 클릭 이벤트 -> 검색 화면 이동
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let type = self?.viewModel.selectedType else { return }
                let vc = SearchViewController(viewModel: SearchViewModel(type))
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 웹툰 클릭 시 웹페이지로 이동
        tableView.rx.modelSelected(Webtoon.self)
            .subscribe({ [weak self] webtoon in
                guard let urlString = webtoon.element?.url, let url = URL(string: urlString) else { return }
                let safariView: SFSafariViewController = SFSafariViewController(url: url)
                self?.present(safariView, animated: true)
            })
            .disposed(by: disposeBag)
        
        // ------------------------------
        //     OUTPUT
        // ------------------------------
        
         // 선택된 서비스 이름 표시
         viewModel.selectedWebtoonType
             .map({ $0.rawValue })
             .bind(to: titleLabel.rx.text)
             .disposed(by: disposeBag)
         
        
        // 웹툰 표시
        // 1. 서비스 타입 변경으로 인해 웹툰 처음으로 가져왔을 때 스크롤 상단이동 & 로딩창 표시
        // 2. tableView Cell 웹툰 바인딩
         viewModel.allPosts
            .do(onNext: { [weak self] webtoons in
                if webtoons.count <= APIInfo.LimitNum{
                    self?.tableView.scrollToRow(at: NSIndexPath(row: NSNotFound, section: 0) as IndexPath, at: .top, animated: false)
                    LoadingIndicator.hideLoading()
                }
            })
            .bind(to: tableView.rx.items(cellIdentifier: WebtoonCell.identifier, cellType: WebtoonCell.self)) {
                 _, item, cell in

                cell.onData.onNext(item)
                cell.selectionStyle = .none
             }
             .disposed(by: disposeBag)
        
        
        // 페이징에 따른 스피너뷰 표시
        viewModel.showFooter
           .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isShow in
               
                self?.tableView.tableFooterView = isShow ? self?.spinnerFooter : nil
            })
            .disposed(by: disposeBag)
     }
 }

