## Monsoon Season: Exploring Rainfall and Temperature Trends during India's Monsoon Season

![](https://tarnmoor.files.wordpress.com/2020/01/picnorteyucatan.jpg)

### *Pipeline*
Please note in the description below, `T` stands for "At terminal" and `C` stands for "In Rstudio console". A `task`, denoted here by the placeholder `task-name`, is essentially a unit of work. It is operationalized as directory of the same name containing at least a folder housing the executable code (`src`), a within directory makefile (`makefile`) for orchestrating that task, and a folder for storing the results of that task (`output`). Many, though not all, tasks also contain `hand` and `R` folders. The former contains text files that are manually modified to modify the analysis. The latter contains executable files with task-specific functions.

This pipeline's style/design is heavily indebted to Patrick Ball's principled data processing philosophy. Here are links to a [recorded talk](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjFmPXD54LvAhUCh-AKHSsLA_4QwqsBMAx6BAhGEAg&url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DZSunU9GQdcI&usg=AOvVaw3xYiypWeIZnqZDxdKUnK1J) and an [article]() by Patrick Ball detailing that philosophy.

To run the pipeline on your local machine follow the steps below.

1. Clone the repository into `desired_directory`:
    - `T`: `cd desired_directory`
    - `T`: `git clone` the SSH clone url

2. Run the code on your local machine:

    1. Set your working directory to the root of the project folder. Either
        - `T`: `cd parole_forums`
        - `C`: `setwd("../parole_forums")`

    2. Confirm your working directory is at the root of the project directory
        - `T`: `pwd`
        - `C`: `getwd()`

    3. Run entire pipeline
        - `T`: `make all`

    4. Run singular task(s)
        - `T`: `cd task-name && make all`
        - `C`: `setwd("task-name"); source("src/task-name.r")`

    5. Run singular task as a local job (within Rstudio)
        - Open the script within the task's `src` folder
        - Hit Ctrl/Command + Shift + J
        - Make sure the path to the script is correct
        - Make sure the working directory is the task folder
        - Hit Enter

To test that code works, follow major step 2 above except where otherwise directed:

3. Run entire pipeline: `T`: `make clean && make all`

4. Run singular task(s):
      - `T`: `cd task-name && make clean && make all`
      - `C`: `setwd("task-name"); unlink("output", recursive = TRUE); source("src/task-name.r")`

Lastly, at any level of the project, use `make help` to learn about other helpful make commands/shortcuts you can run to help orient yourself.
