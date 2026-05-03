---
name: testing-impl
description: 测试实施方案和策略
---

# Testing Implementation Skill

多语言单元测试实现指南，涵盖JUnit(Java)、Jest(JavaScript/TypeScript)和pytest(Python)。

## JUnit (Java)

### 安装依赖

```xml
<!-- Maven -->
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>5.9.2</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <version>5.1.1</version>
    <scope>test</scope>
</dependency>
```

### 基础测试

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    private Calculator calculator;
    
    @BeforeEach
    void setUp() {
        calculator = new Calculator();
    }
    
    @Test
    void shouldAddTwoNumbers() {
        assertEquals(5, calculator.add(2, 3));
    }
    
    @Test
    void shouldThrowExceptionWhenDividingByZero() {
        assertThrows(ArithmeticException.class, () -> {
            calculator.divide(10, 0);
        });
    }
}
```

### 参数化测试

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

@ParameterizedTest
@CsvSource({
    "1, 1, 2",
    "2, 3, 5",
    "10, 20, 30"
})
void shouldAddNumbers(int a, int b, int expected) {
    assertEquals(expected, calculator.add(a, b));
}
```

---

## Jest (JavaScript/TypeScript)

### 安装

```bash
# npm
npm install --save-dev jest

# TypeScript支持
npm install --save-dev ts-jest @types/jest
```

### 基础测试

```javascript
// math.test.js
const { add, multiply } = require('./math');

describe('Math functions', () => {
  beforeEach(() => {
    // 每个测试前的设置
  });

  test('should add two numbers correctly', () => {
    expect(add(2, 3)).toBe(5);
  });

  test('should multiply two numbers correctly', () => {
    expect(multiply(4, 5)).toBe(20);
  });

  test('should handle edge cases', () => {
    expect(add(0, 0)).toBe(0);
    expect(add(-1, 1)).toBe(0);
  });
});
```

### 异步测试

```javascript
test('should fetch user data', async () => {
  const user = await fetchUser(1);
  expect(user).toHaveProperty('name');
  expect(user.id).toBe(1);
});

// 或使用resolves/rejects
expect(fetchUser(1)).resolves.toHaveProperty('name');
```

### Mock函数

```javascript
const mockFn = jest.fn();
mockFn.mockReturnValue(42);

// Mock模块
jest.mock('./api', () => ({
  fetchData: jest.fn().mockResolvedValue({ data: [] })
}));

// Spy
const spy = jest.spyOn(object, 'method');
expect(spy).toHaveBeenCalledWith('arg1', 'arg2');
```

### Snapshot测试

```javascript
test('component renders correctly', () => {
  const tree = renderer.create(<MyComponent />).toJSON();
  expect(tree).toMatchSnapshot();
});
```

---

## pytest (Python)

### 安装

```bash
pip install pytest pytest-cov pytest-mock
```

### 基础测试

```python
# test_calculator.py
import pytest
from calculator import Calculator

class TestCalculator:
    @pytest.fixture
    def calc(self):
        return Calculator()
    
    def test_add(self, calc):
        assert calc.add(2, 3) == 5
        assert calc.add(-1, 1) == 0
    
    def test_divide(self, calc):
        assert calc.divide(10, 2) == 5
        
        with pytest.raises(ZeroDivisionError):
            calc.divide(10, 0)
```

### Fixture

```python
import pytest

@pytest.fixture(scope="module")
def database():
    db = Database()
    db.connect()
    yield db
    db.disconnect()

@pytest.fixture
def sample_data():
    return {
        "name": "Test",
        "value": 42
    }
```

### 参数化测试

```python
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (10, 20, 30),
    (-1, 1, 0),
])
def test_add_parametrized(a, b, expected, calc):
    assert calc.add(a, b) == expected
```

### Mock

```python
from unittest.mock import Mock, patch, MagicMock

def test_with_mock():
    mock_obj = Mock()
    mock_obj.method.return_value = 42
    
    result = mock_obj.method()
    assert result == 42

# Patch装饰器
@patch('module.ClassName')
def test_with_patch(MockClass):
    mock_instance = MockClass.return_value
    mock_instance.method.return_value = 'mocked'
```

### 运行测试

```bash
# 运行所有测试
pytest

# 运行特定文件
pytest test_calculator.py

# 运行特定测试
pytest test_calculator.py::TestCalculator::test_add

# 显示详细输出
pytest -v

# 生成覆盖率报告
pytest --cov=src --cov-report=html
```

---

## 测试原则

### AAA模式 (Arrange-Act-Assert)

```python
def test_example():
    # Arrange - 准备
    input_data = [1, 2, 3]
    expected = 6
    
    # Act - 执行
    result = sum(input_data)
    
    # Assert - 验证
    assert result == expected
```

### FIRST原则

- **F**ast: 测试应该快速执行
- **I**ndependent: 测试应该相互独立
- **R**epeatable: 测试应该可重复，结果一致
- **S**elf-validating: 测试应该自我验证（布尔结果）
- **T**imely: 及时编写测试

### 代码覆盖率目标

- 行覆盖率：> 80%
- 分支覆盖率：> 70%
- 关键业务逻辑：100%

## CI集成

### GitHub Actions 示例

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      # Java + JUnit
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Run JUnit Tests
        run: mvn test
      
      # Node + Jest
      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Run Jest Tests
        run: npm test
      
      # Python + pytest
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Run pytest
        run: pytest --cov=src
```
