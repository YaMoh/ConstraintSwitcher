//
//  ConstraintSwitcher.swift
//  ConstraintSwitcher
//
//  Created by Yaser on 07/09/16.
//  Copyright © 2016 Bespoke Code AB. All rights reserved.
//

import Foundation

import UIKit

protocol ConstraintSwitcher: class {
    func loadConstraints(primaryConstraints primaryConstraints: [NSLayoutConstraint],
                                            primaryTag: Int,
                                            secondaryConstraints: [NSLayoutConstraint],
                                            secondaryTag: Int);

    func switchConstraints(animated: Bool, completion: ConstraintSwitcherCompletedClosure?);
    func activateConstraintWithTag(tag: Int, animated: Bool, completion: ConstraintSwitcherCompletedClosure?);
    func isConstraintActive(tag: Int?) -> Bool;
}

/**
 * Class which helps toggle between different constraints.
 */
typealias ConstraintSwitcherCompletedClosure = ()->()

final class DefaultConstraintSwitcher: ConstraintSwitcher {

    //Configuration
    private let animationTime = 0.75

    private var primaryConstraints:      [NSLayoutConstraint]?
    private var secondaryConstraints:    [NSLayoutConstraint]?

    private var primaryConstraintsTag:   Int?
    private var secondaryConstraintsTag: Int?

    //MARK: - Public functions

    func loadConstraints(primaryConstraints primaryConstraints: [NSLayoutConstraint],
                                            primaryTag: Int,
                                            secondaryConstraints: [NSLayoutConstraint],
                                            secondaryTag: Int) {

        self.primaryConstraints = primaryConstraints
        self.secondaryConstraints = secondaryConstraints

        self.primaryConstraintsTag = primaryTag
        self.secondaryConstraintsTag = secondaryTag
    }

    func switchConstraints(animated: Bool, completion: ConstraintSwitcherCompletedClosure?) {
        let animationTime = animated ? self.animationTime : 0

        let primaryConstraintActive = self.isConstraintActive(self.primaryConstraintsTag)
        let toActivate = primaryConstraintActive ? self.secondaryConstraints : self.primaryConstraints
        let toDeactivate = primaryConstraintActive ? self.primaryConstraints : self.secondaryConstraints

        let view = self.primaryConstraints?.first?.firstItem as? UIView
        UIView.animateWithDuration(animationTime,
                                   delay: 0,
                                   options: [.LayoutSubviews],
                                   animations: {
                                    self.deactivate(toDeactivate)
                                    self.activate(toActivate)
                                    view?.superview?.layoutIfNeeded()
            }, completion: { (completed: Bool) in
                completion?()
        })


    }

    func activateConstraintWithTag(tag: Int, animated: Bool, completion: ConstraintSwitcherCompletedClosure?) {
        guard !self.isConstraintActive(tag) else {
            return
        }

        self.switchConstraints(animated, completion: completion)
    }

    func isConstraintActive(tag: Int?) -> Bool {
        if tag == primaryConstraintsTag {
            return self.primaryConstraints?.first?.active == true
        }

        return self.secondaryConstraints?.first?.active == true
    }

    //MARK: - Private functions
    private func deactivate(constraints: [NSLayoutConstraint]?) {
        constraints?.forEach { (constraint: NSLayoutConstraint) in
            constraint.active = false
        }
    }

    private func activate(constraints: [NSLayoutConstraint]?) {
        constraints?.forEach { (constraint: NSLayoutConstraint) in
            constraint.active = true
        }
    }
}
