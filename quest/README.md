# Quest 提示

每个 Phase 有两层提示：第一层只告诉你方向，第二层（点开折叠）直接给出命令。

建议先只看第一层，自己试五分钟，实在卡住再点开第二层。点开不扣分，但自己想出来的东西记得更牢。

---

## Phase 1：走出迷宫

**目标**：从 `quest/phase1/` 一层层往下走，走到最深处，读出那里的文件。

**第一层提示**：每到一层，先 `ls` 看看有哪些文件夹，挑一个 `cd` 进去。如果里面只有一个 `nope.txt`，说明走错了，`cd ..` 回到上一层换一个。名字太长就敲前几个字母再按 `Tab`。

<details><summary>卡住了点我</summary>

```
cd quest/phase1
ls
cd 某个文件夹名      # 敲前几个字母后按 Tab 补全
ls                   # 如果只看到 nope.txt：
cat nope.txt
cd ..                # 回上一层，换另一个文件夹
```

一直重复「`ls` → `cd` → 走错就 `cd ..`」，直到某一层里出现一个 `.txt` 文件而不是 `nope.txt`，用 `cat 文件名` 打开它。

迷路了随时敲 `pwd`，它会告诉你现在在哪个文件夹。

</details>

---

## Phase 2：看不见的文件

**目标**：找到 `quest/phase2/` 里那个默认不显示的文件，读出它的内容。

**第一层提示**：`ls` 默认会把名字以 `.` 开头的文件藏起来，给它加个参数让它「全部显示」。

<details><summary>卡住了点我</summary>

macOS：

```
cd quest/phase2
ls -a
cat .文件名
```

Windows（PowerShell）：

```
cd quest/phase2
ls -Force
cat .文件名
```

> Windows 的同学可能会发现：不加 `-Force`，那个点开头的文件也显示出来了。这是因为「点开头即隐藏」是 macOS / Linux 的约定，Windows 判断隐藏用的是另一套文件属性。命令照样记住，以后到了服务器上（基本都是 Linux）一定用得上。

</details>

---

## Phase 3：大海捞针

**目标**：在 `quest/phase3/notes/` 的 40 个文件里，找出唯一一个含有口令的。

**第一层提示**：不要一个个打开。让命令行替你「在文件内容里搜索」口令开头那几个固定的字符。

<details><summary>卡住了点我</summary>

Windows（PowerShell）：PowerShell 里没有 `grep`，用它自带的 `Select-String`，意思一样：

```
cd quest/phase3
Select-String -Pattern "HEBUT{" -Path notes\*
```

macOS：

```
cd quest/phase3
grep -r "HEBUT{" .
```

输出的每一行形如 `文件名:行号:内容`，口令就在内容里。

</details>

---

## Phase 4：翻旧账

**目标**：找到一个已经被删除的文件，读出它被删除之前的内容。

**第一层提示**：工作区里找不到的东西，去 git 历史里找。先列出所有提交，找到那条「删除」的说明；它的上一个版本里，文件还在。

<details><summary>卡住了点我</summary>

以下命令都在 `git-quest` 文件夹（仓库最外层）里敲。

```
git log --oneline -- quest/
```

找到说明里写着「移除」的那一行，记下它前面的编号（下面用 `a1b2c3d` 代替，请换成你自己看到的）。先看看那次提交删了哪个文件：

```
git show --stat a1b2c3d
```

输出里会有一行 `quest/某某某.txt | 5 -----`，这就是被删掉的文件的完整路径。

那次提交已经把文件删掉了，所以要看它的**上一次**提交。在编号后面加一个 `^` 就表示「上一次」：

```
git show a1b2c3d^:quest/某某某.txt
```

注意：冒号前后没有空格；路径开头不要加 `/`；必须写到文件名并带 `.txt`。只写 `quest/` 的话，git 只会列出文件夹里有哪些文件，不会显示内容。

> 也可以不用 `^`：在 `git log --oneline` 里，删除那一行**正下方**的那一行就是上一次提交，直接用它的编号，效果一样。

</details>
