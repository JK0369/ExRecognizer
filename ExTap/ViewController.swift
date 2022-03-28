//
//  ViewController.swift
//  ExTap
//
//  Created by Jake.K on 2022/03/28.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import RxGesture

class ViewController: UIViewController {
  private let gestureLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 26)
    $0.text = "탭 카운트 = 0"
  }
  private let layer1View = UIView().then {
    $0.backgroundColor = .orange
    $0.isUserInteractionEnabled = false
    let label = UILabel().then {
      $0.text = "layer1"
      $0.textColor = .white
    }
    $0.addSubview(label)
    label.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(20)
    }
  }
  private let layer2View = UIView().then {
    $0.isUserInteractionEnabled = false
    $0.backgroundColor = .blue
    let label = UILabel().then {
      $0.text = "layer2"
      $0.textColor = .white
    }
    $0.addSubview(label)
    label.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(26)
    }
  }
  
  private let disposeBag = DisposeBag()
  private var count = 0 {
    didSet {
      self.gestureLabel.text = "탭 카운트 = \(count)"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.addSubview(self.gestureLabel)
    self.view.addSubview(self.layer1View)
    self.layer1View.addSubview(self.layer2View)
    
    self.gestureLabel.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
      $0.centerX.equalToSuperview()
    }
    self.layer1View.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 120, left: 100, bottom: 120, right: 100))
    }
    self.layer2View.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 50, left: 55, bottom: 50, right: 50))
    }
    
    Observable
      .merge(
        self.layer1View.rx.tapGesture(configuration: { [weak self] gestureRecognizer, delegate in
          guard let ss = self else { return }
          gestureRecognizer.delegate = ss
          delegate.simultaneousRecognitionPolicy = .never
        })
        .asObservable(),
        self.view.rx.tapGesture(configuration: { [weak self] gestureRecognizer, delegate in
          guard let ss = self else { return }
          gestureRecognizer.delegate = ss
          delegate.simultaneousRecognitionPolicy = .never
        })
        .asObservable()
      )
      .when(.recognized)
      .bind { [weak self] _ in self?.count = (self?.count ?? 0) + 1 }
      .disposed(by: self.disposeBag)
  }
}

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    guard touch.view?.isDescendant(of: self.layer1View) == false else { return false }
    return true
  }
}
