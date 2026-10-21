.pragma library

function cells(year, month, firstWeekday) {
    const first = new Date(year, month, 1);
    const offset = (first.getDay() - firstWeekday % 7 + 7) % 7;
    const dates = [];
    for (let i = 0; i < 42; i++)
        dates.push(new Date(year, month, i - offset + 1));
    return dates;
}
