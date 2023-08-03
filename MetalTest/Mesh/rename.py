# 读取原始 .obj 文件
with open("Temple.obj", "r") as file:
    lines = file.readlines()

vertices = []

# 解析文件内容，存储顶点数值到数组中
for line in lines:
    if line.startswith("v "):
        vertex = line.strip().split()[1:]
        vertices.append(vertex)

# 缩小顶点数值
scaled_vertices = []
for vertex in vertices:
    scaled_vertex = [float(x) / 100 for x in vertex]
    scaled_vertices.append(scaled_vertex)

# 写入新的 .obj 文件
with open("Temple2.obj", "w") as file:
    for line in lines:
        if line.startswith("v "):
            original_vertex = line.strip().split()[1:]
            scaled_vertex = scaled_vertices.pop(0)
            scaled_line = "v " + " ".join(map(str, scaled_vertex))
            file.write(scaled_line + "\n")
        else:
            file.write(line)
