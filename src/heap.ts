export default class Heap extends Map<number, any> {
  counter: number = 5
  constructor () {
    super()
    super.set(1, null) // 1 is reserved for null
    super.set(2, undefined) // 2 is reserved for undefined
    super.set(3, true) // 3 is reserved for true
    super.set(4, false) // 4 is reserved for false
  }

  put (value: any): number {
    if (value === null) return 1
    if (value === undefined) return 2
    if (value === true) return 3
    if (value === false) return 4
    
    const key = this.counter++
    if (this.counter >= 10_000) this.counter = 5
    super.set(key, value)
    return key // pointer to the value
  }
}
