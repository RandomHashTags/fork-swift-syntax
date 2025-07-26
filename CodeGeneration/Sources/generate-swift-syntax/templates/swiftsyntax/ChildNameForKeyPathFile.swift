//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import SwiftSyntax
import SwiftSyntaxBuilder
import SyntaxSupport
import Utils

let childNameForKeyPathFile = SourceFileSyntax(leadingTrivia: copyrightHeader) {
  try! FunctionDeclSyntax(
    """
    /// If the keyPath is one from a layout structure, return the property name
    /// of it.
    @_spi(RawSyntax)
    public func childName(_ keyPath: AnyKeyPath) -> String?
    """
  ) {
    try! VariableDeclSyntax("let keyPathString = \"\\(keyPath)\"")
    try! SwitchExprSyntax("switch keyPathString") {
      let cases = cases().joined(separator: ",\n")
      SwitchCaseSyntax(
        """
        case \(raw: cases):
          guard let identifier = keyPathString.split(separator: ".", maxSplits: 1).last else { return nil }
          return String(identifier)
        """
      )
      SwitchCaseSyntax(
        """
        default:
          return nil
        """
      )
    }
  }
}

private func cases() -> [String] {
  var equal = [String]()
  for node in NON_BASE_SYNTAX_NODES.compactMap(\.layoutNode) {
    for child in node.children {
      let childMemberCallName = "\(child.memberCallName)"
      if childMemberCallName == child.identifier.description {
        equal.append("\"\\\\\(node.type.syntaxBaseName).\(childMemberCallName)\"")
      } else {
        fatalError("unequal")
      }
    }
  }
  return equal
}