# Docker 常用命令速查

个人Docker学习笔记，记录日常开发中频繁使用的命令。

## 容器生命周期

```bash
# 运行并进入交互式容器
docker run -it --rm ubuntu:22.04 bash

# 后台运行并映射端口
docker run -d -p 8080:80 --name my-nginx nginx

# 查看日志
docker logs -f --tail 100 my-nginx

# 进入运行中容器
docker exec -it my-nginx /bin/bash
# 清理悬空镜像
docker image prune -f

# 清理未使用的卷（危险）
docker volume prune

# 一键清理（生产环境慎用）
docker system prune -a
24/03

### `notes/react-hooks-patterns.md`

```markdown
# React Hooks 设计模式实践

记录在实际项目中总结的Hooks使用模式。

## 1. 数据获取模式

### 基础useFetch

```javascript
const useFetch = (url) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Network response was not ok');
        const json = await response.json();
        setData(json);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [url]);

  return { data, loading, error };
};
