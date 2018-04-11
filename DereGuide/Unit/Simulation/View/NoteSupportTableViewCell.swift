//
//  NoteSupportTableViewCell.swift
//  DereGuide
//
//  Created by zzk on 2017/5/18.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit
import SnapKit

class NoteSupportTableViewCell: UITableViewCell {
    
    var stackView: UIStackView!
    
    let comboIndexLabel = UILabel()
    let skillBoostLabel = UILabel()
    let perfectLockLabel = UILabel()
    let comboContinueLabel = UILabel()
    let healLabel = UILabel()
    let damageGuardLabel = UILabel()
    let lifeLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        let font = UIFont.boldSystemFont(ofSize: 16)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        comboIndexLabel.textColor = .allType
        
        skillBoostLabel.font = font
        skillBoostLabel.textColor = .cute
        
        perfectLockLabel.font = font
        perfectLockLabel.textColor = .master
        
        comboContinueLabel.font = font
        comboContinueLabel.textColor = .visual
        
        healLabel.textColor = .life
        
        damageGuardLabel.font = font
        damageGuardLabel.textColor = .parade
       
        lifeLabel.textColor = .life
        
        stackView = UIStackView(arrangedSubviews: [comboIndexLabel, skillBoostLabel,
                                                        perfectLockLabel, comboContinueLabel,
                                                        healLabel, damageGuardLabel, lifeLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 5
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with log: LSLog) {
        
        let attributeStr = NSMutableAttributedString(string: String(format: "%d", log.noteIndex), attributes: [NSAttributedStringKey.foregroundColor: UIColor.allType])
        if log.comboFactor > 1 {
            attributeStr.append(NSAttributedString(string: String(format: "(x%.1f)", log.comboFactor), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)]))
        }
        comboIndexLabel.text = String(log.noteIndex)
        
        skillBoostLabel.text = log.skillBoost == 1000 ? "-" : "○"
        
        perfectLockLabel.text = log.perfectLock ? "○" : "-"
        
        perfectLockLabel.text = (log.strongPerfectLock && log.skillBoost > 1000) ? "●" : perfectLockLabel.text
        
        comboContinueLabel.text = log.comboContinue ? "○" : "-"
        
        damageGuardLabel.text = log.guard ? "○" : "-"

        if log.lifeRestore == 0 {
            healLabel.text = "-"
            healLabel.textColor = .darkGray
        } else if log.lifeRestore > 0 {
            healLabel.text = "+\(log.lifeRestore)"
            healLabel.textColor = .life
        } else {
            healLabel.text = "\(log.lifeRestore)"
            healLabel.textColor = .red
        }
        
        if log.currentLife == 0 {
            backgroundColor = UIColor.lightGray.lighter()
        } else {
            backgroundColor = .white
        }
        lifeLabel.text = String(log.currentLife)
        
    }
}
