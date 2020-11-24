# coding standard

* pointers: `int* ptr`
* if else: 
    ```c
    if (condition) {

    } else if (condition2) {

    } else {

    }
    ```

* naming functions and variables: `aaa_bbb`

* c headers:
    header.h
    ```c
    #ifndef __HEADER_H__
    #define __HEADER_H__

    #ifdef __cplusplus
    extern "C" {
    #endif

    /* all the includes */

    /* all declarations */

    #ifdef __cplusplus
    }
    #endif

    #endif /* __HEADER_H__ */
    ```

* comments:
  ```c
  /* single line comment */

  /*
    multi
    line
    comment
  */
  ```

* professionalism > simplicity and readability > performance and efficiency