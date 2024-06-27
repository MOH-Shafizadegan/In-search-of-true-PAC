# In-search-of-true-PAC
Discussing different methods of calculating Phase Amplitude Coupling

# PAC Method
- Using Wavelet (CWT) transform as time frequency decomposition
- Calculating the tf-decompostion, then windowing signal wherever needed e.g. in calculating PAC dynamic
- Using MVL for calculating PAC


# Descripption
- **Synthesizing the signal:** 
    - The phase amplitude coupled signal has been generated following proposed method at the this [article](https://www.bing.com/search?pglt=675&q=tf-mvl+pac+article&cvid=d8cba1ff838e46c28e06b9a8381a2f28&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCTEyNjY4ajBqMagCALACAA&FORM=ANNTA1&PC=W069).
    - Generating a signal composed of:
        - Random gaussian nosie of 1 second
        - coupled signal one:
            - Amplitude frequency: 40 Hz
            - Phase frequency: 5 Hz
        - coupled signal two:
            - Amplitude frequency: 60 Hz
            - Phase frequency: 9 Hz
        - coupled signal one + additive noise
        - coupled signal two + additive noise

- **PAC Comodulogram**
    - Generating comodulogram for each of the 5 sections of the signal        
        
- **PAC dynamic**
    - Generating PAC dynamic through all of the 5 second signal
    - Window length = 200 ms
    - Window shift step = 100 ms

- **Statistical test**
    - Sample size: 100
    - Population 1:
        - Coupled signals:
            - Random Phase freq in range: [4, 7]
            - Random Amp freq in range: [38, 42]
    - Population 2:
        - Coupled signals:
            - Random Phase freq in range: [8, 11]
            - Random Amp freq in range: [55, 65]
    - Null hypothesis:
        - PAC in range [4,8] and [35, 45] is higher for second population


    