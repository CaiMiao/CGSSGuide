//
//  TeamSimulationController.swift
//  CGSSGuide
//
//  Created by zzk on 2017/5/16.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit
import StoreKit
import CoreData

class TeamSimulationController: BaseTableViewController, TeamCollectionPage {
    
    var unit: Unit! {
        didSet {
            tableView?.reloadData()
            resetDataGrid()
        }
    }
    
    fileprivate func resetDataGrid() {
        let cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TeamSimulationMainBodyCell
        cell?.clearSimulationGrid()
        cell?.clearCalculationGrid()
    }
    
    var simulatorType: CGSSLiveSimulatorType = .normal {
        didSet {
            tableView.reloadRows(at: [IndexPath.init(row: 3, section: 0)], with: .automatic)
        }
    }
    
    var grooveType: CGSSGrooveType? {
        didSet {
            tableView.reloadRows(at: [IndexPath.init(row: 4, section: 0)], with: .automatic)
        }
    }
    
    var scene: CGSSLiveScene? {
        didSet {
            tableView.reloadRows(at: [IndexPath.init(row: 1, section: 0)], with: .automatic)
        }
    }
    
    lazy var liveSelectionViewController: TeamSongSelectViewController = {
        let vc = TeamSongSelectViewController()
        vc.delegate = self
        return vc
    }()
    
    var simulationResult: LSResult?
    
    weak var currentSimulator: CGSSLiveSimulator?
    
    deinit {
        currentSimulator?.cancelSimulating()
    }
    
    var titles = [NSLocalizedString("得分分布", comment: ""),
                  NSLocalizedString("高级计算", comment: ""),
                  NSLocalizedString("得分详情", comment: ""),
                  NSLocalizedString("辅助技能详情", comment: ""),
                  NSLocalizedString("高级选项", comment: "")]
   
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()

        tableView.register(TeamSimulationTeamCell.self, forCellReuseIdentifier: TeamSimulationTeamCell.description())
        tableView.register(TeamSimulationLiveSelectCell.self, forCellReuseIdentifier: TeamSimulationLiveSelectCell.description())

        tableView.register(TeamSimulationCommonCell.self, forCellReuseIdentifier: TeamSimulationCommonCell.description())
        tableView.register(TeamSimulationAppealEditingCell.self, forCellReuseIdentifier: TeamSimulationAppealEditingCell.description())
        tableView.register(TeamSimulationModeSelectionCell.self, forCellReuseIdentifier: TeamSimulationModeSelectionCell.description())
        tableView.register(TeamSimulationMainBodyCell.self, forCellReuseIdentifier: TeamSimulationMainBodyCell.description())
        tableView.register(TeamSimulationDescriptionCell.self, forCellReuseIdentifier: TeamSimulationDescriptionCell.description())
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if unit.hasChanges {
            unit.managedObjectContext?.saveOrRollback()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationTeamCell.description(), for: indexPath) as! TeamSimulationTeamCell
            cell.setup(with: unit)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationLiveSelectCell.description(), for: indexPath) as! TeamSimulationLiveSelectCell
            cell.setup(with: scene)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationAppealEditingCell.description(), for: indexPath) as! TeamSimulationAppealEditingCell
            cell.setup(with: unit)
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationModeSelectionCell.description(), for: indexPath) as! TeamSimulationModeSelectionCell
            cell.setup(with: NSLocalizedString("歌曲模式", comment: ""), rightDetail: simulatorType.description, rightColor: simulatorType.color)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationModeSelectionCell.description(), for: indexPath) as! TeamSimulationModeSelectionCell
            cell.setup(with: NSLocalizedString("Groove类别", comment: ""), rightDetail: grooveType?.description ?? "n/a", rightColor: grooveType?.color ?? Color.allType)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationMainBodyCell.description(), for: indexPath) as! TeamSimulationMainBodyCell
            cell.delegate = self
            return cell
        case 6...10:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationCommonCell.description(), for: indexPath) as! TeamSimulationCommonCell
            cell.setup(with: titles[indexPath.row - 6])
            return cell
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: TeamSimulationDescriptionCell.description(), for: indexPath) as! TeamSimulationDescriptionCell
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.row {
        case 0:
            if let unit = self.unit {
                let vc = TeamEditingController()
                vc.parentUnit = unit
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            navigationController?.pushViewController(liveSelectionViewController, animated: true)
        case 3:
            let cell = tableView.cellForRow(at: indexPath)
            showActionSheetOfLiveModeSelection(at: cell as? TeamSimulationModeSelectionCell)
        case 4:
            if self.grooveType != nil {
                let cell = tableView.cellForRow(at: indexPath)
                showActionSheetOfGrooveTypeSelection(at: cell as? TeamSimulationModeSelectionCell)
            }
        case 6:
            checkScoreDistribution()
        case 7:
            gotoAdvanceCalculation()
        case 8:
            checkScoreDetail()
        case 9:
            checkSupportSkillDetail()
        case 10:
            let vc = TeamAdvanceOptionsController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func checkScoreDistribution() {
        if let result = self.simulationResult, result.scores.count > 0 {
            let vc = TeamSimulationScoreDistributionController(result: result)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            UIAlertController.showHintMessage(NSLocalizedString("至少进行一次模拟计算之后才能查看得分分布", comment: ""), in: nil)
        }
    }

    func checkScoreDetail() {
        if let scene = self.scene {
            let vc = LiveSimulatorViewController()
            let coordinator = LSCoordinator.init(unit: unit, scene: scene, simulatorType: simulatorType, grooveType: grooveType)
            vc.coordinator = coordinator
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showNotSelectSongAlert()
        }
    }
    
    func checkSupportSkillDetail() {
        if let scene = self.scene {
            let vc = LiveSimulatorSupportSkillsViewController()
            let coordinator = LSCoordinator.init(unit: unit, scene: scene, simulatorType: simulatorType, grooveType: grooveType)
            vc.coordinator = coordinator
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            showNotSelectSongAlert()
        }
    }
    
    func gotoAdvanceCalculation() {
        if let result = self.simulationResult, result.scores.count > 0, let scene = scene {
            let vc = TeamAdvanceCalculationController(result: result)
            let coordinator = LSCoordinator.init(unit: unit, scene: scene, simulatorType: simulatorType, grooveType: grooveType)
            let formulator = coordinator.generateLiveFormulator()
            vc.formulator = formulator
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            UIAlertController.showHintMessage(NSLocalizedString("至少进行一次模拟计算之后才能进行高级计算", comment: ""), in: nil)
        }
    }
    
    private func showActionSheetOfLiveModeSelection(at cell: TeamSimulationModeSelectionCell?) {
        let alvc = UIAlertController.init(title: NSLocalizedString("选择歌曲模式", comment: "弹出框标题"), message: nil, preferredStyle: .actionSheet)
        
        if let cell = cell {
            alvc.popoverPresentationController?.sourceView = cell.rightLabel
            alvc.popoverPresentationController?.sourceRect = CGRect(x: 0, y: cell.rightLabel.bounds.maxY / 2, width: 0, height: 0)
        } else {
            alvc.popoverPresentationController?.sourceView = tableView
            alvc.popoverPresentationController?.sourceRect = CGRect(x: tableView.frame.maxX / 2, y: tableView.frame.maxY / 2, width: 0, height: 0)
        }
        alvc.popoverPresentationController?.permittedArrowDirections = .right
        for simulatorType in CGSSLiveSimulatorType.all {
            alvc.addAction(UIAlertAction.init(title: simulatorType.description, style: .default, handler: { (a) in
                self.simulatorType = simulatorType
                if [.normal, .parade].contains(simulatorType) {
                    self.grooveType = nil
                } else if self.grooveType == nil {
                    self.grooveType = CGSSGrooveType.init(cardType: self.unit.leader.card?.cardType ?? .cute)
                }
            }))
        }
        alvc.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "弹出框按钮"), style: .cancel, handler: nil))
        self.present(alvc, animated: true, completion: nil)
    }
    
    func showActionSheetOfGrooveTypeSelection(at cell: TeamSimulationModeSelectionCell?) {
        let alvc = UIAlertController.init(title: NSLocalizedString("选择Groove类别", comment: "弹出框标题"), message: nil, preferredStyle: .actionSheet)
        
        if let cell = cell {
            alvc.popoverPresentationController?.sourceView = cell.rightLabel
            alvc.popoverPresentationController?.sourceRect = CGRect(x: 0, y: cell.rightLabel.bounds.maxY / 2, width: 0, height: 0)
        } else {
            alvc.popoverPresentationController?.sourceView = tableView
            alvc.popoverPresentationController?.sourceRect = CGRect(x: tableView.frame.maxX / 2, y: tableView.frame.maxY / 2, width: 0, height: 0)
        }

        alvc.popoverPresentationController?.permittedArrowDirections = .right
        for grooveType in CGSSGrooveType.all {
            alvc.addAction(UIAlertAction.init(title: grooveType.rawValue, style: .default, handler: { (a) in
                self.grooveType = grooveType
            }))
        }
        alvc.addAction(UIAlertAction.init(title: NSLocalizedString("取消", comment: "弹出框按钮"), style: .cancel, handler: nil))
        self.present(alvc, animated: true, completion: nil)
    }
       
}

extension TeamSimulationController: TeamEditingControllerDelegate {
    func teamEditingController(_ teamEditingController: TeamEditingController, didModify units: Set<Unit>) {
        if units.contains(self.unit) {
            if let vc = pageCollectionController as? TeamDetailController {
                vc.setNeedsReloadTeam()
                vc.reloadTeamIfNeeded()
            }
        }
    }
    
}

extension TeamSimulationController: TeamSimulationTeamCellDelegate {
    
    func teamSimulationTeamCell(_ teamSimulationTeamCell: TeamSimulationTeamCell, didClick cardIcon: CGSSCardIconView) {
        if let id = cardIcon.cardId, let card = CGSSDAO.shared.findCardById(id) {
            let cardDVC = CardDetailViewController()
            cardDVC.card = card
            navigationController?.pushViewController(cardDVC, animated: true)
        }

    }
    
}

extension TeamSimulationController: BaseSongTableViewControllerDelegate {
    
    func baseSongTableViewController(_ baseSongTableViewController: BaseSongTableViewController, didSelect liveScene: CGSSLiveScene) {
        self.scene = liveScene
    }
}

extension TeamSimulationController: TeamSimulationAppealEditingCellDelegate {
    
    func teamSimulationAppealEditingCell(_ teamSimulationAppealEditingCell: TeamSimulationAppealEditingCell, didUpdateAt selectionIndex: Int, supportAppeal: Int, customAppeal: Int) {
        unit.customAppeal = Int64(customAppeal)
        unit.supportAppeal = Int64(supportAppeal)
        unit.usesCustomAppeal = (selectionIndex == 1)
        // save action cause tableView.reloadData(), delayed save to avoid cycling save
        // not save here
    }
}

extension TeamSimulationController: TeamSimulationMainBodyCellDelegate {

    fileprivate func showUnknownSkillAlert() {
        UIAlertController.showHintMessage(NSLocalizedString("队伍中存在未知的技能类型，计算结果可能不准确。", comment: ""), in: nil)
    }
    
    fileprivate func showNotSelectSongAlert() {
        UIAlertController.showHintMessage(NSLocalizedString("请先选择歌曲", comment: "弹出框正文"), in: nil)
    }
    
    func startSimulate(_ teamSimulationMainBodyCell: TeamSimulationMainBodyCell) {
        let cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TeamSimulationMainBodyCell
        
        let doSimulationBy = { [weak self] (simulator: CGSSLiveSimulator, times: UInt) in
            var options = LSOptions()
            if LiveSimulationAdvanceOptionsManager.default.considerOverloadSkillsTriggerLifeCondition {
                options.insert(.overloadLimitByLife)
            }
            simulator.simulate(times: times, options: options, progress: { (a, b) in
                DispatchQueue.main.async {
                    // self.teamDV.advanceProgress.progress = Float(a) / Float(b)
                    cell?.simulationButton.setTitle(NSLocalizedString("计算中...", comment: "") + "(\(String.init(format: "%d", a * 100 / b))%)", for: .normal)
                }
            }, callback: { (result, logs) in
                DispatchQueue.main.async { [weak self] in
                    cell?.setupSimulationResult(value1: result.get(percent: 1), value2: result.get(percent: 5), value3: result.get(percent: 20), value4: result.get(percent: 50))
//                    print(result.average)
                    cell?.stopSimulationAnimating()
                    self?.simulationResult = result
                }
            })
        }
        
        if let scene = self.scene {
            cell?.clearSimulationGrid()
            cell?.startSimulationAnimating()
            if unit.hasUnknownSkills() {
                showUnknownSkillAlert()
            }
            let coordinator = LSCoordinator.init(unit: unit, scene: scene, simulatorType: simulatorType, grooveType: grooveType)
            let simulator = coordinator.generateLiveSimulator()
            currentSimulator = simulator
            DispatchQueue.global(qos: .userInitiated).async {
                #if DEBUG
                    doSimulationBy(simulator, 5000)
                #else
                    doSimulationBy(simulator, UInt(LiveSimulationAdvanceOptionsManager.default.simulationTimes))
                #endif
            }
        } else {
            showNotSelectSongAlert()
            cell?.stopSimulationAnimating()
        }
        
    }
    
    func startCalculate(_ teamSimulationMainBodyCell: TeamSimulationMainBodyCell) {
        let cell = tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TeamSimulationMainBodyCell
        if let scene = self.scene {
            cell?.clearCalculationGrid()
            if unit.hasUnknownSkills() {
                showUnknownSkillAlert()
            }
            let coordinator = LSCoordinator.init(unit: unit, scene: scene, simulatorType: simulatorType, grooveType: grooveType)
            let simulator = coordinator.generateLiveSimulator()
            let formulator = coordinator.generateLiveFormulator()
            cell?.setupAppeal(coordinator.fixedAppeal ?? coordinator.appeal)
            
            simulator.simulateOptimistic1(options: [], callback: { (result, logs) in
                cell?.setupCalculationResult(value1: coordinator.fixedAppeal ?? coordinator.appeal, value2: result.average, value3: formulator.maxScore, value4: formulator.averageScore)
                cell?.resetCalculationButton()
            })
            
            /// first time using calculator in team detail view controller, shows app store rating alert in app.
            if #available(iOS 10.3, *) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    if !UserDefaults.standard.hasRated {
                        SKStoreReviewController.requestReview()
                        UserDefaults.standard.hasRated = true
                    }
                })
            }
            
        } else {
            showNotSelectSongAlert()
            cell?.resetCalculationButton()
        }
    }
    
    func cancelSimulating(_ teamSimulationMainBodyCell: TeamSimulationMainBodyCell) {
        currentSimulator?.cancelSimulating()
    }
}
