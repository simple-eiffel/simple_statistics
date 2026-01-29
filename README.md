# simple_statistics

[Documentation](https://simple-eiffel.github.io/simple_statistics/) •
[GitHub](https://github.com/simple-eiffel/simple_statistics) •
[Issues](https://github.com/simple-eiffel/simple_statistics/issues)

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Eiffel 25.02](https://img.shields.io/badge/Eiffel-25.02-purple.svg)
![DBC: Contracts](https://img.shields.io/badge/DBC-Contracts-green.svg)

Type-safe statistical analysis library for Eiffel with Design by Contract throughout.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

✅ **Production Ready** — v1.0.0
- 43 tests passing, 100% pass rate
- Descriptive statistics, correlation, regression, hypothesis testing
- Design by Contract throughout with verified postconditions

## Quick Start

```eiffel
create stats.make
data := {ARRAY [REAL_64]} << 1.0, 2.0, 3.0, 4.0, 5.0 >>
mean := stats.mean (data)
variance := stats.variance (data)
median := stats.median (data)
```

For complete documentation, see [our docs site](https://simple-eiffel.github.io/simple_statistics/).

## Features

- Descriptive statistics (mean, median, variance, percentiles, quartiles)
- Correlation and covariance analysis
- Linear regression with R² computation
- Hypothesis testing (t-tests, chi-square, ANOVA)
- Data cleaning utilities
- Numerically stable algorithms
- Full contract verification with postconditions

For details, see the [User Guide](https://simple-eiffel.github.io/simple_statistics/user-guide.html).

## Installation

```bash
# Add to your ECF:
<library name="simple_statistics" location="$SIMPLE_EIFFEL/simple_statistics/simple_statistics.ecf"/>
```

## License

MIT License - See LICENSE file

## Support

- **Docs:** https://simple-eiffel.github.io/simple_statistics/
- **GitHub:** https://github.com/simple-eiffel/simple_statistics
- **Issues:** https://github.com/simple-eiffel/simple_statistics/issues
