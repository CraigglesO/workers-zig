export default class Heap extends Map<number, any> {
  counter: number = 7
  constructor () {
    super()
    super.set(1, null) // 1 is reserved for null
    super.set(2, undefined) // 2 is reserved for undefined
    super.set(3, true) // 3 is reserved for true
    super.set(4, false) // 4 is reserved for false
    super.set(5, Infinity) // 5 is reserved for Infinity
    super.set(6, NaN) // 6 is reserved for NaN
  }

  put (value: any): number {
    if (value === null) return 1
    else if (value === undefined) return 2
    else if (value === true) return 3
    else if (value === false) return 4
    else if (value === Infinity) return 5
    else if (Number.isNaN(value)) return 6
    
    const key = this.counter++
    if (this.counter >= 10_000) this.counter = 7
    super.set(key, value)
    return key // pointer to the value
  }
}
