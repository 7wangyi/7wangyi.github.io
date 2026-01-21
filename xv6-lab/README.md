# xv6启动流程实践

## 项目概述
完成MIT xv6操作系统启动流程分析实践，理解从BIOS到内核main函数的完整过程。

## 任务完成情况

### 任务1：Fork并成功启动xv6
- ✅ Fork xv6仓库到个人GitHub
- ✅ 成功编译xv6系统
- ✅ 使用QEMU成功启动到shell提示符

### 任务2：启动流程注释
- ✅ bootasm.S：添加从实模式到保护模式的注释
- ✅ bootmain.c：添加ELF内核加载过程注释  
- ✅ entry.S：添加内核入口点注释

### 任务3：启动过程可视化
- ✅ bootmain.c：添加`[BOOT]`阶段标记注释
- ✅ entry.S：添加`[KERNEL] ENTRY POINT`标记
- ✅ main.c：添加`[KERNEL] main() started`注释

## 启动流程理解
1. **bootasm.S**：16位实模式 → 启用A20 → 加载GDT → 32位保护模式
2. **bootmain.c**：读取ELF头部 → 验证格式 → 加载程序段 → 跳转内核
3. **entry.S**：设置栈指针 → 调用main()函数
4. **main.c**：内核初始化开始

## 运行结果
成功启动xv6系统，可执行基本命令：
##总结
学会了操作系统xv6的相关知识，并学会了Ubuntu的应用，使在github上的操作更加熟练，希望能对下学期的课程操作系统有一定的帮助
