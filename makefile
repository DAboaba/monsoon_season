## all  : Run all tasks in this pipeline
all:
	cd read_merge_raw_data && make

## clean : Remove ALL auto-generated files
.PHONY : clean
clean :
	rm -r */output

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
