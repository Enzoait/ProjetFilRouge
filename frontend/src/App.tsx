import { useEffect, useState } from "react";

type Todo = {
  id: number;
  text: string;
};

const App = () => {
  const [count, setCount] = useState<number>(0);
  const [todos, setTodos] = useState<Todo[]>([]);

  useEffect(() => {
    fetch("http://localhost:3005/todos")
      .then((response) => response.json())
      .then((todos: Todo[]) => {
        setTodos(todos);
      });
  }, []);

  console.log(todos);

  return (
    <>
      <button onClick={() => setCount((count) => count + 1)}>
        count is {count}!!
      </button>

      <div>
        {todos.map((todo) => (
          <div key={todo.id}>{todo.text}</div>
        ))}
      </div>
    </>
  );
};

export default App;
