import Testing
@testable import StocksCore

struct TrieTests {
  @Test("Should throw for unmatched length") func testInit() async throws {
    #expect(throws: Error.self) { try Trie([], values: [1]) }
    #expect(throws: Error.self) { try Trie(["One"], values: []) }
  }
  
  @Test("Should return only for exact matches") func testContainsExactMatch() async throws {
    let trie = Trie("Hello, world", value: 1)
    #expect(trie.contains(prefix: "Hello, world", shouldBeExactMatch: true))
    #expect(trie.contains(prefix: "hello, world", shouldBeExactMatch: true), "Should be case in-sensitive")
    #expect(trie.contains(prefix: "ello, world", shouldBeExactMatch: true) == false)
    #expect(trie.contains(prefix: "Hello, worl", shouldBeExactMatch: true) == false)
    #expect(trie.contains(prefix: "", shouldBeExactMatch: true) == false)
    #expect(trie.contains(prefix: "!", shouldBeExactMatch: true) == false)
  }
  
  @Test("Should return partial matches") func testContainsPartialMatches() async throws {
    let trie = Trie("Hello, world", value: 1)
    #expect(trie.contains(prefix: "Hello, ", shouldBeExactMatch: false))
    #expect(trie.contains(prefix: "hello, worl", shouldBeExactMatch: false), "Should be case in-sensitive")
    #expect(trie.contains(prefix: "ello, world", shouldBeExactMatch: false) == false)
    #expect(trie.contains(prefix: "", shouldBeExactMatch: true) == false)
    #expect(trie.contains(prefix: "!", shouldBeExactMatch: true) == false)
  }
  
  @Test("Should return the value") func testValue() async throws {
    let trie = try Trie(["One", "Two"], values: [1, 2])
    #expect(trie.value(for: "One") == 1)
    #expect(trie.value(for: "Two") == 2)
    #expect(trie.value(for: "") == nil)
    #expect(trie.value(for: "Z") == nil)
  }
  
  @Test("Should return values for partial matches") func testValues() async throws {
    let trie = try Trie(["One", "OneHundred", "Two", "TwoHundred"], values: [1, 100, 2, 200])
    #expect(trie.values(for: "One") == [100, 1])
    #expect(trie.values(for: "OneHundred") == [100])
    #expect(trie.values(for: "Two") == [200, 2])
    #expect(trie.values(for: "") == [])
    #expect(trie.values(for: "Z") == [])
  }
}
