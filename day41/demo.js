
export default function demo() {
  console.log("default export -This is a demo function from day41/demo.js");
}

function fun1(){
    console.log("named export - This is fun1 from day41/demo.js");
}
function fun2(){
    console.log("named export - This is fun2 from day41/demo.js");
}
function fun3(){
    console.log("named export - This is fun3 from day41/demo.js");
}

export {fun1, fun2, fun3};