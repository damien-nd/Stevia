//
//  LeakTests.swift
//  Stevia
//
//  Created by Damien Noel Dubuisson on 04/11/2016.
//  Copyright © 2016 Sacha Durand Saint Omer. All rights reserved.
//

import XCTest
import Stevia

private var instanceCounter = 0

class Leak : NSObject {

    override init() {
        super.init()
        instanceCounter += 1
    }

    deinit {
        instanceCounter -= 1
    }
}

class LeakTests : XCTestCase {

    //MARK: - ReferenceLeak

    func testReference() {
        instanceCounter = 0
        var leak: Leak? = Leak()
        leak = nil

        XCTAssertEqual(instanceCounter, 0)
    }

    //MARK: - TapFunctionLeak

    class TapFunctionLeak : Leak {
        let button = UIButton()
        var value = 0

        override init() {
            super.init()
            button.tap(tap)
        }

        func tap() {
            value += 1
        }
    }

    func testTapFunction() {
        instanceCounter = 0
        var leak: TapFunctionLeak? = TapFunctionLeak()
        leak = nil

        XCTAssertEqual(instanceCounter, 0)
    }

    //MARK: - TapClosureLeak

    class TapClosureLeak : Leak {
        let button = UIButton()
        var value = 0

        override init() {
            super.init()
            button.tap { [unowned self] in
                self.value += 1
            }
        }
    }

    func testTapClosure() {
        instanceCounter = 0
        var leak: TapClosureLeak? = TapClosureLeak()
        leak = nil

        XCTAssertEqual(instanceCounter, 0)
    }

    //MARK: - OnFunctionLeak

    class OnFunctionLeak : Leak {
        var value = 0

        override init() {
            super.init()
            on("OnFunctionLeak", onFunc)
        }

        func onFunc() {
            value += 1
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func testOnFunction() {
        instanceCounter = 0
        var leak: OnFunctionLeak? = OnFunctionLeak()
        leak = nil

        XCTAssertEqual(instanceCounter, 0)
    }

    //MARK: - OnClosureLeak

    class OnClosureLeak : Leak {
        var value = 0

        override init() {
            super.init()
            on("OnClosureLeak") { [unowned self] in
                self.value += 1
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func testOnClosure() {
        instanceCounter = 0
        var leak: OnClosureLeak? = OnClosureLeak()
        leak = nil

        XCTAssertEqual(instanceCounter, 0)
    }
}
