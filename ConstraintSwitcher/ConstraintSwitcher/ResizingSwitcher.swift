//
//  ResizingSwitcher.swift
//  ConstraintSwitcher
//
//  Created by Yaser on 07/09/16.
//  Copyright © 2016 Bespoke Code AB. All rights reserved.
//

import Foundation


import UIKit

/**
 * Specific case of ConstraintSwitcher which provides some context. This
 * switcher handles extended/contracted constraints
 */
final class ResizingSwitcher: NSObject {

    enum ResizeTag: Int {
        case expanded
        case contracted
    }

    @IBOutlet var expandedConstraints:   [NSLayoutConstraint]?
    @IBOutlet var contractedConstraints: [NSLayoutConstraint]?

    private let constraintSwitcher: ConstraintSwitcher

    //MARK: - Init functions
    required override init() {
        self.constraintSwitcher = DefaultConstraintSwitcher()
    }

    init(constraintSwitcher: ConstraintSwitcher) {
        self.constraintSwitcher = constraintSwitcher
    }

    //MARK: - Public functions

    @IBAction func expand() {
        self.expand(true)
    }

    func expand(animated: Bool) {
        self.setupConstraintSwitcherIfNeeded()
        self.constraintSwitcher.activateConstraintWithTag(ResizeTag.expanded.rawValue, animated: animated, completion: nil)
    }

    @IBAction func contract() {
        self.contract(true)
    }

    func contract(animated: Bool) {
        self.setupConstraintSwitcherIfNeeded()
        self.constraintSwitcher.activateConstraintWithTag(ResizeTag.contracted.rawValue, animated: animated, completion: nil)
    }

    @IBAction func toggle() {
        self.toggle(true)
    }

    func toggle(animated: Bool) {
        self.setupConstraintSwitcherIfNeeded()
        if self.isExpanded() {
            self.contract(animated)
        } else {
            self.expand(animated)
        }
    }

    func isExpanded() -> Bool {
        return constraintSwitcher.isConstraintActive(ResizeTag.expanded.rawValue)
    }

    //MARK: - Private functions

    private func setupConstraintSwitcherIfNeeded() {
        guard let expandedConstraints = self.expandedConstraints else {
            return
        }

        guard let contractedConstraints = self.contractedConstraints else {
            return
        }

        var primaryConstraints = expandedConstraints
        var primaryTag = ResizeTag.expanded
        var secondaryConstraints = contractedConstraints
        var secondaryTag = ResizeTag.contracted
        if contractedConstraints.first?.active == true {
            primaryConstraints = contractedConstraints
            primaryTag = .contracted
            secondaryConstraints = expandedConstraints
            secondaryTag = .expanded
        }

        self.constraintSwitcher.loadConstraints(primaryConstraints: primaryConstraints,
                                                primaryTag: primaryTag.rawValue,
                                                secondaryConstraints: secondaryConstraints,
                                                secondaryTag: secondaryTag.rawValue)
    }
}
