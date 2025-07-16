import { Model, AllowNull, AutoIncrement, Column, DataType, HasMany, PrimaryKey, Table, ForeignKey, BelongsTo } from "sequelize-typescript";
import { TripDay } from './trip-day.model';

@Table({
  tableName: 'Activities',
  timestamps: true,
})
export class Activity extends Model {
  @PrimaryKey
  @AutoIncrement
  @Column(DataType.INTEGER)
  id!: number;

  @ForeignKey(() => TripDay)
  @AllowNull(false)
  @Column(DataType.INTEGER)
  tripDayId!: number;

  @BelongsTo(() => TripDay)
  tripDay!: TripDay;

  @AllowNull(true) // Matches onDelete: 'SET NULL' in migration
  @Column(DataType.STRING)
  activity_type?: string;

  @AllowNull(false)
  @Column(DataType.STRING)
  name!: string;

  @Column(DataType.TEXT)
  description?: string; // Optional

  @Column(DataType.STRING)
  location?: string; // Optional

  @Column(DataType.TIME)
  startTime?: string; // TIME is typically represented as a string in JS

  @Column(DataType.TIME)
  endTime?: string; // TIME is typically represented as a string in JS
}