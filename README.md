# kiwinest

kiwinest (Windows/Mac/Linux)

## Background

This project is a starting point for a RSA secure solution for SOHO.

The active use of SOHOs and small businesses, and the contribution of developers may affect the generalization of security and this project.

- [What is RSA? wikipedia:]([https://docs.flutter.dev/get-started/codelab](https://ko.wikipedia.org/wiki/RSA_%EC%95%94%ED%98%B8)

For help getting started or contribute with this project, view the Guide documents: User's Guide & Developer's Guide.

## Purpose

RSA is widely used as an algorithm for encryption and digital signature. However, there is no commercial or personal paid or open source software. Kiwinest was developed to expand the presence of enterprise/personal RSA encryption software in the age of information flooding.

## Project Perspective

Kiwinest is basically an RSA encryption program. Starting with the Python code encryption source code 'RSA2C.py ' produced in 2021, Kiwinest added document encryption, access management, and GUI to it. Kiwinest will be released through Github within the second quarter of 2024 and can contribute to the project in the Github community.

## Constraints

Since the program is distributed as a General Public License (GPL), the GPL must be specified when forking the program. Also, licenses that are not compatible with GPL cannot be used in forked programs.

## Interface Requirements

There should be a user interface that allows users to run programs and perform encryption/decryption operations. The user interface should also be intuitive and easy to use and provide clear instructions on encryption and decryption.

## Functional Requirements

The program uses the RSA algorithm to generate public and private keys. In addition, the program must be given the ability to safely manage and cycle the generated key, and to back up or recover the key to the user.

The user may encrypt and decrypt the selected file, and the encrypted file must maintain the same shape as the original when decrypted.

The program should display an appropriate error message in the event of an unexpected situation. An error handling mechanism should be implemented, and it should be explicitly displayed on the interface so that the user can understand the error and solve the problem. (We have to solve this first)

## Maintainability & Portability

This program should clearly define processes and responsibilities for bug fixes. In addition, the community should specify how to prioritize new features or functional improvements, document the priorities and processes of security updates, and provide updates quickly.

This program must ensure operating system compatibility so that the program can operate on the specified operating systems. In addition, the community should document the requirements for compatible data types and file system versions, and ensure compatibility with as many different data types or file systems as possible. (Refer to the Guide documentation)
