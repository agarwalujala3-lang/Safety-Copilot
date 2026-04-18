const app = require("./app");

const port = Number(process.env.PORT || 4002);

app.listen(port, () => {
  console.log(`Real backend running on http://localhost:${port}`);
});
