//
//  DefaultConstraintSwitcherTests.swift
//  ConstraintSwitcher
//
//  Created by Yaser on 07/09/16.
//  Copyright © 2016 Bespoke Code AB. All rights reserved.
//

import XCTest
@testable import ConstraintSwitcher

class DefaultConstraintSwitcherTests: XCTestCase {

    typealias TestObjectsTuple = (primaryConstraints: [NSLayoutConstraint], primaryTag: Int, secondaryConstraints: [NSLayoutConstraint], secondaryTag: Int, testObject: DefaultConstraintSwitcher)

    //MARK: - Test switching constraints

    /**
     * Given:   Constraints set
     * When:    The constraints are switched with animation
     * Then:    The active constraints changes
     */
    func testConstraintSwitchNormalCaseAnimated() {
        let testTuple = self.createTestObjects()

        testTuple.testObject.switchConstraints(true, completion: nil)

        sleep(1)

        XCTAssertFalse(self.constraintsActive(testTuple.primaryConstraints))
        XCTAssertTrue(self.constraintsActive(testTuple.secondaryConstraints))
        XCTAssertTrue(self.layoutIfNeededCalled(testTuple.primaryConstraints.first!))
    }

    /**
     * Given:   Constraints set
     * When:    The constraints are switched without animation
     * Then:    The active constraints changes
     */
    func testConstraintSwitchNormalCaseNotAnimated() {
        let testTuple = self.createTestObjects()

        testTuple.testObject.switchConstraints(false, completion: nil)

        sleep(1)

        XCTAssertFalse(self.constraintsActive(testTuple.primaryConstraints))
        XCTAssertTrue(self.constraintsActive(testTuple.secondaryConstraints))
        XCTAssertTrue(self.layoutIfNeededCalled(testTuple.primaryConstraints.first!))
    }

    /**
     * Given:   Constraints not set
     * When:    The constraints are switched
     * Then:    Nothing happens
     */
    func testConstraintSwitchNoneSet() {
        let testObject = DefaultConstraintSwitcher()

        testObject.switchConstraints(true, completion: nil)

        // Shouldnt crash
    }

    //MARK: - Test activating specific constraint

    /**
     * Given:   Constraints set
     * When:    The non-active constraint is activated by tag (animated)
     * Then:    It becomes active
     */
    func testActivateNonActiveConstraintByTagAnimated() {
        let testTuple = self.createTestObjects()

        testTuple.testObject.activateConstraintWithTag(testTuple.secondaryTag, animated: true, completion: nil)

        sleep(1)

        XCTAssertFalse(self.constraintsActive(testTuple.primaryConstraints))
        XCTAssertTrue(self.constraintsActive(testTuple.secondaryConstraints))
        XCTAssertTrue(self.layoutIfNeededCalled(testTuple.primaryConstraints.first!))
    }

    /**
     * Given:   Constraints set
     * When:    The non-active constraint is activated by tag (not animated)
     * Then:    It becomes active
     */
    func testActivateNonActiveConstraintByTagNotAnimated() {
        let testTuple = self.createTestObjects()

        testTuple.testObject.activateConstraintWithTag(testTuple.secondaryTag, animated: false, completion: nil)

        sleep(1)

        XCTAssertFalse(self.constraintsActive(testTuple.primaryConstraints))
        XCTAssertTrue(self.constraintsActive(testTuple.secondaryConstraints))
        XCTAssertTrue(self.layoutIfNeededCalled(testTuple.primaryConstraints.first!))
    }

    /**
     * Given:   Constraints set
     * When:    The active constraint is activated by tag
     * Then:    Nothing happens
     */
    func testReActivateByTag() {
        let testTuple = self.createTestObjects()

        testTuple.testObject.activateConstraintWithTag(testTuple.primaryTag, animated: false, completion: nil)

        sleep(1)

        XCTAssertTrue(self.constraintsActive(testTuple.primaryConstraints))
        XCTAssertFalse(self.constraintsActive(testTuple.secondaryConstraints))
        XCTAssertFalse(self.layoutIfNeededCalled(testTuple.primaryConstraints.first!))
    }

    /**
     * Given:   Constraints not set
     * When:    The active constraint is activated by tag
     * Then:    Nothing happens
     */
    func testActivateByTagNoConstraints() {
        let testObject = DefaultConstraintSwitcher()

        testObject.activateConstraintWithTag(2, animated: false, completion: nil)

        sleep(1)
        // Shouldnt crash
    }


    //MARK: - Test check if constraint is active by tag

    /**
     * Given:   Constraints set
     * When:    Checking if the active constraints are active by tag
     * Then:    Returns true
     */
    func testIsActiveForActiveTag() {
        let testTuple = self.createTestObjects()

        let testValue = testTuple.testObject.isConstraintActive(testTuple.primaryTag)

        XCTAssertTrue(testValue)
    }

    /**
     * Given:   Constraints set
     * When:    Checking if the inactive constraints are active by tag
     * Then:    Returns false
     */
    func testIsActiveForInactiveTag() {
        let testTuple = self.createTestObjects()

        let testValue = testTuple.testObject.isConstraintActive(testTuple.secondaryTag)

        XCTAssertFalse(testValue)
    }

    /**
     * Given:   Constraints not set
     * When:    Checking if any tag is active
     * Then:    Returns false
     */
    func testIsActiveWithoutConstraints() {
        let testObject = DefaultConstraintSwitcher()

        let testValue = testObject.isConstraintActive(3)

        XCTAssertFalse(testValue)
    }


    /**
     * Given:   Constraints set
     * When:    Checking if any tag is active for invalid tag
     * Then:    Returns false
     */
    func testIsActiveInvalidTag() {
        let testTuple = self.createTestObjects()

        let testValue = testTuple.testObject.isConstraintActive(3)

        XCTAssertFalse(testValue)
    }

    //MARK: - Erroneous setup tests

    /**
     * Given:   Constraints set with the same tags
     * When:    Running any function
     * Then:    Nothing should crash
     */
    func testSetupSameTags() {
        let tag = 3
        let testTuple = self.createTestObjects(primaryTag: tag, secondaryTag: tag)

        // Ignore all return values. It should not crash - thats the point. The
        // behaviour should be undefined
        testTuple.testObject.isConstraintActive(tag)
        testTuple.testObject.activateConstraintWithTag(tag, animated: true, completion: nil)
        testTuple.testObject.activateConstraintWithTag(tag, animated: false, completion: nil)
        testTuple.testObject.switchConstraints(true, completion: nil)
        testTuple.testObject.switchConstraints(false, completion: nil)

    }

    /**
     * Given:   Empty constraint lists set
     * When:    Running any function
     * Then:    Nothing should crash
     */
    func testEmptyConstraints() {
        let primaryTag = 1
        let secondaryTag = 2

        let testObject = DefaultConstraintSwitcher()
        testObject.loadConstraints(primaryConstraints: [], primaryTag: primaryTag, secondaryConstraints: [], secondaryTag: secondaryTag)

        // Ignore all return values. It should not crash - thats the point. The
        // behaviour should be undefined
        testObject.isConstraintActive(primaryTag)
        testObject.isConstraintActive(secondaryTag)
        testObject.activateConstraintWithTag(primaryTag, animated: true, completion: nil)
        testObject.activateConstraintWithTag(secondaryTag, animated: false, completion: nil)
        testObject.switchConstraints(true, completion: nil)
        testObject.switchConstraints(false, completion: nil)

    }

    //MARK: - Private functions

    fileprivate func createTestObjects(primaryTag: Int = 0, secondaryTag: Int = 1) -> TestObjectsTuple {
        let primaryConstraints = [self.createConstraint(active: true), self.createConstraint(active: true)]
        let secondaryConstraints = [self.createConstraint(active: false), self.createConstraint(active: false)]

        let testObject = DefaultConstraintSwitcher()
        testObject.loadConstraints(primaryConstraints: primaryConstraints, primaryTag: primaryTag, secondaryConstraints: secondaryConstraints, secondaryTag: secondaryTag)

        return  (primaryConstraints: primaryConstraints, primaryTag: primaryTag, secondaryConstraints: secondaryConstraints, secondaryTag: secondaryTag, testObject: testObject)
    }


    fileprivate func createConstraint(active: Bool) -> NSLayoutConstraint {
        let constraint = TestConstraint(firstItem: self.createFirstItemView())
        constraint.isActive = active
        return constraint
    }

    fileprivate func createFirstItemView() -> TestView {
        return TestView(superView: TestView())
    }

    fileprivate func constraintsActive(_ constraints: [NSLayoutConstraint]) -> Bool {
        constraints.forEach { (constraint: NSLayoutConstraint) in
            if constraint.isActive == false {
                return false
            }
        }

        return true
    }

    fileprivate func layoutIfNeededCalled(_ constraint: NSLayoutConstraint) -> Bool {
        if let view = constraint.firstItem as? TestView {
            return view.superView!.layoutIfNeededCalled
        }

        return false
    }
}

private final class TestConstraint: NSLayoutConstraint {

    init(firstItem: TestView) {
        _firstItem = firstItem
    }

    fileprivate var _active: Bool = false
    override var isActive: Bool {
        get {
            return _active
        }

        set {
            _active = newValue
        }
    }

    fileprivate var _firstItem: AnyObject
    override var firstItem: AnyObject {
        get {
            return _firstItem
        }

        set {
            _firstItem = newValue
        }
    }
}

private final class TestView: UIView {

    override var superview: UIView? {
        get {
            return self.superView
        }
    }

    var superView: TestView?
    init(superView: TestView? = nil) {
        super.init(frame: CGRect.zero)
        self.superView = superView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var layoutIfNeededCalled: Bool = false
    override func layoutIfNeeded() {
        self.layoutIfNeededCalled = true
        super.layoutIfNeeded()
    }
}
