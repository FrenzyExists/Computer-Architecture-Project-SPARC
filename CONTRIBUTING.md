# Contributing to SPARC V8 Fantastica

Thank you for your interest in contributing to SPARC V8 Fantastica! We welcome contributions from everyone, whether you are an undergraduate student or an experienced developer. By contributing to this project, you can help make it even better.

To ensure a smooth and collaborative development process, please review the following guidelines before making contributions.

## Getting Started

To get started with contributing to SPARC V8 Fantastica, follow these steps:

1. Fork the repository on GitHub.
2. Clone your forked repository to your local machine.
3. Make the necessary changes and improvements to the codebase.
4. Test your changes to ensure they work as expected.
5. Commit your changes and push them to your forked repository.
6. Submit a pull request (PR) to the main repository.

## Guidelines for Contributions

### Code Style

Please follow the established code style and conventions when making changes to the Verilog code. Consistent code formatting enhances readability and maintainability:

- Use meaningful and descriptive variable, module, and signal names.

- Indent code blocks using spaces (not tabs) for consistent formatting.

- Use proper spacing around operators and parentheses for clarity.

- Align module, port, and signal declarations for readability.

- Use consistent capitalization conventions for keywords, constants, and user-defined identifiers.

- Add comments to explain complex code or provide context when necessary.

### Branching

When working on new features or bug fixes, create a new branch from the `main` branch. Name your branch descriptively to indicate the purpose of your changes.

### Commit Messages

Write clear and concise commit messages that describe the purpose of each commit. Use imperative verbs and keep the message brief but informative.

### Testing

Ensure that your changes do not introduce any regressions or break existing functionality. Whenever possible, include appropriate test cases and ensure they pass successfully.

- Update the `wizard.sh` script, which is responsible for building modules and tester modules. Ensure that the testing option executes the `analyze.py` Python script, which performs timing analysis.

- Test files should generate a VCD (Value Change Dump) file that can be used with GTKWave for waveform analysis. Include instructions on how to generate the VCD file and specify the required naming conventions for the VCD files.

- When submitting a contribution that includes changes to test files, provide screenshots or visual evidence of the tester file execution and GTKWave output. These screenshots should demonstrate that the module is running as expected and follows SPARC V8 standards.


## Community Guidelines

When participating in discussions and interactions related to SPARC V8 Fantastica, we kindly ask you to adhere to the following guidelines:

- Be respectful and considerate of others' opinions and ideas.
- Avoid offensive, discriminatory, or disrespectful language or behavior.
- Stay on topic and focus discussions on project-related matters.
- Provide constructive feedback and suggestions.

## How to Report Issues or Bugs

If you encounter any bugs, issues, or have suggestions for improvement, please report them using the GitHub issue tracker. Provide as much information as possible to help us understand and reproduce the problem. Provide the following info:

- A clear and descriptive title summarizing the issue.
- Detailed steps to reproduce the bug.
- Screenshots of the GTKWave runs showing the issue, if applicable.
- Any relevant error messages or console output.


## Conclusion

We appreciate your contributions and efforts to make SPARC V8 Fantastica a successful and valuable project. Together, we can create something great! If you have any questions or need further assistance, feel free to reach out to the project maintainers.

Happy contributing!

