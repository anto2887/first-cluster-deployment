#Question number 2)
aws s3 ls

#3)
aws ecs list-task-definitions

#4)
#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}
