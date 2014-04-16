; ModuleID = 'conv.c'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct._IO_FILE = type { i32, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, %struct._IO_marker*, %struct._IO_FILE*, i32, i32, i64, i16, i8, [1 x i8], i8*, i64, i8*, i8*, i8*, i8*, i64, i32, [20 x i8] }
%struct._IO_marker = type { %struct._IO_marker*, %struct._IO_FILE*, i32 }

@sdt_conv_size = global i32 0, align 4
@sdt_conv_c = common global i32* null, align 8
@.str = private unnamed_addr constant [15 x i8] c"/tmp/sdt.0.out\00", align 1
@.str1 = private unnamed_addr constant [3 x i8] c"w+\00", align 1
@.str2 = private unnamed_addr constant [4 x i8] c"%u\0A\00", align 1
@.str3 = private unnamed_addr constant [13 x i8] c"/tmp/sdt.out\00", align 1

; Function Attrs: nounwind uwtable
define void @sdt_conv_init(i32 %lnsiz) #0 {
entry:
  %lnsiz.addr = alloca i32, align 4
  store i32 %lnsiz, i32* %lnsiz.addr, align 4
  %0 = load i32* %lnsiz.addr, align 4
  %conv = zext i32 %0 to i64
  %call = call noalias i8* @calloc(i64 %conv, i64 4) #3
  %1 = bitcast i8* %call to i32*
  store i32* %1, i32** @sdt_conv_c, align 8
  %2 = load i32* %lnsiz.addr, align 4
  store i32 %2, i32* @sdt_conv_size, align 4
  ret void
}

; Function Attrs: nounwind
declare noalias i8* @calloc(i64, i64) #1

; Function Attrs: nounwind uwtable
define void @sdt_conv_for(i32 %lnno) #0 {
entry:
  %lnno.addr = alloca i32, align 4
  store i32 %lnno, i32* %lnno.addr, align 4
  %0 = load i32* %lnno.addr, align 4
  %1 = load i32* @sdt_conv_size, align 4
  %cmp = icmp uge i32 %0, %1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %if.end5

if.end:                                           ; preds = %entry
  %2 = load i32* %lnno.addr, align 4
  %idxprom = zext i32 %2 to i64
  %3 = load i32** @sdt_conv_c, align 8
  %arrayidx = getelementptr inbounds i32* %3, i64 %idxprom
  %4 = load i32* %arrayidx, align 4
  %cmp1 = icmp ult i32 %4, 4096
  br i1 %cmp1, label %if.then2, label %if.end5

if.then2:                                         ; preds = %if.end
  %5 = load i32* %lnno.addr, align 4
  %idxprom3 = zext i32 %5 to i64
  %6 = load i32** @sdt_conv_c, align 8
  %arrayidx4 = getelementptr inbounds i32* %6, i64 %idxprom3
  %7 = load i32* %arrayidx4, align 4
  %inc = add i32 %7, 1
  store i32 %inc, i32* %arrayidx4, align 4
  br label %if.end5

if.end5:                                          ; preds = %if.then, %if.then2, %if.end
  ret void
}

; Function Attrs: nounwind uwtable
define void @sdt_conv_close() #0 {
entry:
  %i = alloca i32, align 4
  %out = alloca %struct._IO_FILE*, align 8
  %call = call %struct._IO_FILE* @fopen(i8* getelementptr inbounds ([15 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([3 x i8]* @.str1, i32 0, i32 0))
  store %struct._IO_FILE* %call, %struct._IO_FILE** %out, align 8
  %0 = load %struct._IO_FILE** %out, align 8
  %1 = load i32* @sdt_conv_size, align 4
  %call1 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %0, i8* getelementptr inbounds ([4 x i8]* @.str2, i32 0, i32 0), i32 %1)
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %2 = load i32* %i, align 4
  %3 = load i32* @sdt_conv_size, align 4
  %cmp = icmp ult i32 %2, %3
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %4 = load %struct._IO_FILE** %out, align 8
  %5 = load i32* %i, align 4
  %idxprom = sext i32 %5 to i64
  %6 = load i32** @sdt_conv_c, align 8
  %arrayidx = getelementptr inbounds i32* %6, i64 %idxprom
  %7 = load i32* %arrayidx, align 4
  %call2 = call i32 (%struct._IO_FILE*, i8*, ...)* @fprintf(%struct._IO_FILE* %4, i8* getelementptr inbounds ([4 x i8]* @.str2, i32 0, i32 0), i32 %7)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %8 = load i32* %i, align 4
  %inc = add nsw i32 %8, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %9 = load %struct._IO_FILE** %out, align 8
  %call3 = call i32 @fileno(%struct._IO_FILE* %9) #3
  %call4 = call i32 @fsync(i32 %call3)
  %10 = load %struct._IO_FILE** %out, align 8
  %call5 = call i32 @fclose(%struct._IO_FILE* %10)
  %call6 = call i32 @rename(i8* getelementptr inbounds ([15 x i8]* @.str, i32 0, i32 0), i8* getelementptr inbounds ([13 x i8]* @.str3, i32 0, i32 0)) #3
  %11 = load i32** @sdt_conv_c, align 8
  %12 = bitcast i32* %11 to i8*
  call void @free(i8* %12) #3
  ret void
}

declare %struct._IO_FILE* @fopen(i8*, i8*) #2

declare i32 @fprintf(%struct._IO_FILE*, i8*, ...) #2

declare i32 @fsync(i32) #2

; Function Attrs: nounwind
declare i32 @fileno(%struct._IO_FILE*) #1

declare i32 @fclose(%struct._IO_FILE*) #2

; Function Attrs: nounwind
declare i32 @rename(i8*, i8*) #1

; Function Attrs: nounwind
declare void @free(i8*) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.5.0 (trunk 206239)"}
