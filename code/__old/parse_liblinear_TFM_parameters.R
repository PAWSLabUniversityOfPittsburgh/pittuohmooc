# 
# given that the read_liblinear_model function was called, and the following variables were set, 
# parse the model vector of parameters into individual parameter groups and pools
# 
# Necessary variable: w, nG, nP, nB, nK
#

#
# Separate parameters
#

offset = 0

# student global intercept (nG-1)
int_student = w[(offset+1):(offset+(nG-1))]
offset = offset + (nG-1)

# behavior global intercept (nB-1)
int_behav = w[(offset+1):(offset+(nB-1))]
offset = offset + (nB-1)

# student intercepts w/in nB-1 behaviors
int_student_wi_behav = matrix(0,nrow=nG,ncol=nB-1)
for(i in 1:(nB-1)) {
  int_student_wi_behav[,i] = w[(offset+1):(offset+(nG))]
  offset = offset + nG
}

# problem intercepts w/in nB-1 behaviors
int_problem_wi_behav = matrix(0,nrow=nP,ncol=nB-1)
for(i in 1:(nB-1)) {
  int_problem_wi_behav[,i] = w[(offset+1):(offset+(nP))]
  offset = offset + nP
}

# behavior slope since previous submission
slope_behav_since_prev_submit = w[(offset+1):(offset+(nB))]
offset = offset + nB

# behavior slope for user
slope_behav_for_user = w[(offset+1):(offset+(nB))]
offset = offset + nB

# behavior slope for problems
slope_behav_for_problem = w[(offset+1):(offset+(nB))]
offset = offset + nB

# slopes for users*behaviors since previous submission
slope_user_wi_behav_since_prev_submit = matrix(0,nrow=nG,ncol=nB)
for(i in 1:nB) {
  slope_user_wi_behav_since_prev_submit[,i] = w[(offset+1):(offset+(nG))]
  offset = offset + nG
}

# slopes for users*behaviors since start of work
slope_user_wi_behav_since_start = matrix(0,nrow=nG,ncol=nB)
for(i in 1:nB) {
  slope_user_wi_behav_since_start[,i] = w[(offset+1):(offset+(nG))]
  offset = offset + nG
}

# slopes for users*behaviors since start of problem
slope_user_wi_behav_since_problem_start = matrix(0,nrow=nG,ncol=nB)
for(i in 1:nB) {
  slope_user_wi_behav_since_problem_start[,i] = w[(offset+1):(offset+(nG))]
  offset = offset + nG
}

# skill intercept (nK-1)
int_skill = w[(offset+1):(offset+(nK-1))]
offset = offset + (nK-1)

# skill intercept w/in problems (nK-1)*nP
int_skill_wi_problem = matrix(0,nrow=nK-1,ncol=nP)
for(i in 1:nP) {
  int_skill_wi_problem[,i] = w[(offset+1):(offset+(nK-1))]
  offset = offset + nK-1
}

# skill slopes
slope_skill = w[(offset+1):(offset+(nK))]
offset = offset + nK

# skill failure slopes
slope_skill_fail = w[(offset+1):(offset+(nK))]
offset = offset + nK

# skill intercept w/in problems nK*nP
slope_skill_wi_problem = matrix(0,nrow=nK,ncol=nP)
for(i in 1:nP) {
  slope_skill_wi_problem[,i] = w[(offset+1):(offset+(nK))]
  offset = offset + nK
}

# skill intercept w/in problems nK*nP
slope_skill_fail_wi_problem = matrix(0,nrow=nK,ncol=nP)
for(i in 1:nP) {
  slope_skill_fail_wi_problem[,i] = w[(offset+1):(offset+(nK))]
  offset = offset + nK
}

# bias
bias = w[offset+1]
offset = offset + 1
