
addUSER.sh脚本主要功能：
	使用直接修改Linux配置文件的方式，为系统添加用户三个用户，管理员，操作员，审计员，及其对应的用户组，永固密码为8位长度，由0-9数字，和大小写26个字母随机组成，同时为Linux配置iptables 规则，关闭其他所有端口，仅开发22端口的功能。