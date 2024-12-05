import Foundation

final public class Trie<T> {
  private var root: TrieNode<T>?
  
  public init() {
    self.root = .init()
  }
  
  public init(_ word: String, value: T) {
    self.root = TrieNode()
    insert(word, value: value)
  }
  
  public init(_ words: [String], values: [T]) throws {
    guard words.count == values.count else {
      throw TrieError("The length of words and values should be equal.")
    }
    
    self.root = TrieNode()
    insert(words, values: values)
  }
  
  public func removeAll() {
    root = TrieNode()
  }
  
  public func insert(_ word: String, value: T) {
    root?.add(word.uppercased(), value: value)
  }
  
  public func insert(_ words: [String], values: [T]) {
    for (word, value) in zip(words, values) {
      root?.add(word.uppercased(), value: value)
    }
  }
  
  public func contains(prefix: String, shouldBeExactMatch: Bool = false) -> Bool {
    guard !prefix.isEmpty, var current = root else { return false }
    
    for character in prefix.uppercased() {
      guard let next = current.children[character] else { break }
      current = next
    }
    
    let isPartialMatch = !shouldBeExactMatch && current.hasParent
    
    return current.isTerminal || isPartialMatch
  }
  
  public func value(for word: String) -> T? {
    var current = root
    
    for character in word.uppercased() {
      guard let child = current?.children[character] else {
        break
      }
      
      current = child
    }
    
    return current?.value
  }
  
  public func values(for prefix: String) -> [T] {
    guard let node = node(for: prefix) else {
      return []
    }
    
    let values = values(in: node, for: prefix)
    
    return if let value = node.value {
      values + [value]
    } else {
      values
    }
  }
  
  private func values(in node: TrieNode<T>?, for prefix: String) -> [T] {
    guard !prefix.isEmpty, let node else { return [] }
    let children = node.children.map(\.value)
    
    return children.compactMap(\.value)
    + children.flatMap { values(in: $0, for: prefix) }
  }
  
  private func node(for prefix: String) -> TrieNode<T>? {
    guard !prefix.isEmpty, var current = root else { return nil }
    
    for character in prefix.uppercased() {
      guard let next = current.children[character] else { break }
      current = next
    }
    
    return current.hasParent ? current : nil
  }
}

// MARK: - TrieNode<T>
private final class TrieNode<T> {
  private(set) var value: T?
  private(set) var children: [Character: TrieNode] = [:]
  var hasParent: Bool { parent != nil }
  private(set) weak var parent: TrieNode<T>?
  private(set) var isTerminal: Bool = false
  private(set) var character: Character?
  
  init(_ character: Character? = nil) {
    self.character = character
  }
  
  func add(_ word: String, value: T?) {
    guard !word.isEmpty else { return }
    
    let firstCharacter = word[word.startIndex]
    
    let child: TrieNode<T>
    if let existingChild = children[firstCharacter] {
      child = existingChild
    } else {
      child = TrieNode(firstCharacter)
      child.parent = self
      children[firstCharacter] = child
    }
    
    if word.count > 1 {
      child.add("\(word.dropFirst())", value: value)
    } else {
      child.isTerminal = true
      child.value = value
    }
  }
}

private struct TrieError: LocalizedError {
  var errorDescription: String?
  
  init(_ errorDescription: String? = nil) {
    self.errorDescription = errorDescription
  }
}
