for folder in {A..Z};do
  # for path in `find ../../../bench/pmark/java/${folder} -name '*.java'`; do
  for path in `ls ../../../../bench/pmark/java/${folder}/*.java`; do
    ./java8 $path
  done
  # ./java8 ../../../bench/pmark/java/${folder}/*.java
done
