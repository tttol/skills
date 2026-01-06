---
name: test code
description: The guideline about test code. Use when implmenting test code.
---
- Follow the Given-When-Then pattern. These represent the three phases of a test.
- Given: Set up your test data, mocks, expected values, and everything else you need.
- When: Execute the method you're testing. Keep this to a single line - each test should focus on one method only. Don't test multiple methods in a single test.
- Then: Verify that you got the expected results.
Here is a sample of Given-When-Then pattern.
```javascript
class Calculator {
  add(a, b) {
    return a + b;
  }
}

describe('Calculator', () => {
  describe('add', () => {
    test('Add two numbers', () => {
      // GIVEN
      const calculator = new Calculator();
      const num1 = 5;
      const num2 = 3;
      const expected = 8;
      
      // WHEN
      const result = calculator.add(num1, num2);
      
      // THEN
      expect(result).toBe(expected);
    });
  });
});

```
- Don't change a method's visibility just to make tests pass (for example, changing private to public).
- Use parameterized test pattern as possinble.
- When performing assertions on an object in your test code, avoid writing an assertThat for every single property of the object. Instead, you should compare the objects directly (or compare the expected object with the actual object).  Here is a sample assertion.
```java
// --- BAD: Manual field-by-field assertions are verbose and harder to maintain ---
var actual = response.getResults().get(0);
assertThat(actual.primaryFlag()).isEqualTo("1");
assertThat(actual.secondaryFlag()).isEqualTo("0");


// --- GOOD: Using recursive comparison against a helper method improves clarity ---
public void test() {
    var actual = response.body();
    
    assertThat(actual)
        .usingRecursiveComparison()
        .isEqualTo(createExpectedResponse());
}

private TargetResponse createExpectedResponse() {
    var expected = new TargetResponse();
    var detail = new DetailInfo();
    
    // Set simplified properties for demonstration
    detail.setIdentifier("ID_001");
    detail.setStatus(ProcessStatus.COMPLETED);
    
    expected.setDetailInfo(detail);
    return expected;
}

```
- Check if the target test passes when you updated a test code. The only thing you should do is run the tests you updated. You don't have to run all of the tests."
- Declare the `expected` variable explicitly. Here is a sample.
```java
// --- BAD: Hard to read because expected value generation and validation rules are mixed ---
var actual = mapper.readValue(responseBody, TargetResponse.class);

assertThat(actual)
    .usingRecursiveComparison()
    .ignoringFields("metadata.timestamp") // Exclude dynamic values like timestamps
    .isEqualTo(createExpectedResponse("ID_001", "Sample Item")); // Inline generation makes it cluttered


// --- GOOD: Clear separation between "What to expect" and "How to compare" ---
var actual = mapper.readValue(responseBody, TargetResponse.class);

// 1. Define the expected object
var expected = createExpectedResponse("ID_001", "Sample Item");

// 2. Perform the assertion with specific rules
assertThat(actual)
    .usingRecursiveComparison()
    .ignoringFields("metadata.timestamp")
    .isEqualTo(expected);
```

