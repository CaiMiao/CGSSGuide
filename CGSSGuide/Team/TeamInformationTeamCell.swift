//
//  TeamInformationTeamCell.swift
//  CGSSGuide
//
//  Created by zzk on 2017/5/20.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

protocol TeamInformationTeamCellDelegate: class  {
    func teamInformationTeamCell(_ teamInformationTeamCell: TeamInformationTeamCell, didClick cardIcon: CGSSCardIconView)
}

class TeamInformationTeamCell: UITableViewCell, CGSSIconViewDelegate {

    var selfLeaderSkillLabel: TeamLeaderSkillView!
    
    var friendLeaderSkillLabel: TeamLeaderSkillView!
    
    var iconStackView: UIStackView!
    
    weak var delegate: TeamInformationTeamCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selfLeaderSkillLabel = TeamLeaderSkillView()
        contentView.addSubview(selfLeaderSkillLabel)
        selfLeaderSkillLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        selfLeaderSkillLabel.arrowDirection = .down

        var icons = [UIView]()
        for _ in 0...5 {
            let icon = CGSSCardIconView()
            icon.delegate = self
            icons.append(icon)
        }
        iconStackView = UIStackView(arrangedSubviews: icons)
        iconStackView.spacing = 5
        iconStackView.distribution = .fillEqually
        
        contentView.addSubview(iconStackView)
        
        iconStackView.snp.makeConstraints { (make) in
            make.top.equalTo(selfLeaderSkillLabel.snp.bottom).offset(3)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.width.equalTo(iconStackView.snp.height).multipliedBy(6).offset(25)
        }
        
        friendLeaderSkillLabel = TeamLeaderSkillView()
        contentView.addSubview(friendLeaderSkillLabel)
        friendLeaderSkillLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconStackView.snp.bottom).offset(3)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
        friendLeaderSkillLabel.arrowDirection = .up
        friendLeaderSkillLabel.descLabel.textAlignment = .right
        
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        let frame = self.iconStackView.convert(self.iconStackView.arrangedSubviews.first?.frame ?? CGRect.zero, to: selfLeaderSkillLabel)
        let frame2 = self.iconStackView.convert(self.iconStackView.arrangedSubviews.last?.frame ?? CGRect.zero, to: friendLeaderSkillLabel)
        selfLeaderSkillLabel.arrowOffset = CGPoint(x: frame.midX - selfLeaderSkillLabel.arrowWidth / 2, y: 0)
        friendLeaderSkillLabel.arrowOffset = CGPoint(x: frame2.midX - friendLeaderSkillLabel.arrowWidth / 2, y: 0)
    }
    
    func setup(with team: CGSSTeam) {
        for i in 0...5 {
            if let teamMember = team[i], let card = teamMember.cardRef, let view = iconStackView.arrangedSubviews[i] as? CGSSCardIconView {
                view.cardId = card.id
            }
        }

        if let selfLeaderRef = team.leader.cardRef {
            selfLeaderSkillLabel.setupWith(text: "\(NSLocalizedString("队长技能", comment: "队伍详情页面")): \(selfLeaderRef.leaderSkill?.name ?? NSLocalizedString("无", comment: ""))\n\(selfLeaderRef.leaderSkill?.getLocalizedExplain(languageType: CGSSGlobal.languageType) ?? "")", backgroundColor: selfLeaderRef.attColor.withAlphaComponent(0.5))
        } else {
            selfLeaderSkillLabel.setupWith(text: "", backgroundColor: Color.allType.withAlphaComponent(0.5))
        }
        if let friendLeaderRef = team.friendLeader.cardRef {
            friendLeaderSkillLabel.setupWith(text: "\(NSLocalizedString("好友技能", comment: "队伍详情页面")): \(friendLeaderRef.leaderSkill?.name ?? "无")\n\(friendLeaderRef.leaderSkill?.getLocalizedExplain(languageType: CGSSGlobal.languageType) ?? "")", backgroundColor: friendLeaderRef.attColor.withAlphaComponent(0.5))
        } else {
            friendLeaderSkillLabel.setupWith(text: "", backgroundColor: Color.allType.withAlphaComponent(0.5))
        }
    }

    func iconClick(_ iv: CGSSIconView) {
        delegate?.teamInformationTeamCell(self, didClick: iv as! CGSSCardIconView)
    }
}
